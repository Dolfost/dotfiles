# Nicotine+ has no remote control, and a second Soulseek client on the same
# account would kick this one off the server. So this plugin opens a unix
# socket inside the data folder (which the container has from the host, see
# containers/systemd/nicotine.container) and answers JSON requests on it:
# one request line per connection, one reply line. The host's `slsk` command
# (nix/modules/user/music/slsk.py) is the client.
#
# It leans on Nicotine+ internals (core.search, core.downloads, the events
# queue), not on the plugin API, which has no search or download calls. It
# was written against 3.3.10; after a Nicotine+ upgrade, `slsk status` and a
# test search are the things to check.
#
# Searches made here are kept away from the GUI on purpose: they are never
# entered in core.search.searches, so no tab opens and the search history
# stays the user's own. Downloads do show up in the GUI's Downloads tab,
# like any other.

import json
import os
import socketserver
import threading
import time

from pynicotine.events import events
from pynicotine.pluginsystem import BasePlugin
from pynicotine.slskmessages import FileSearch
from pynicotine.slskmessages import UserStatus
from pynicotine.slskmessages import increment_token

SEARCH_TTL = 900           # seconds a search keeps collecting and is kept
SEARCH_MAX_FILES = 20000   # per search, then it stops listening
MAIN_THREAD_TIMEOUT = 20


class Plugin(BasePlugin):

    def __init__(self, *args, **kwargs):

        super().__init__(*args, **kwargs)

        self.settings = {
            "socket_name": "agent_api.sock",
            "download_root": "/downloads/claude",
        }
        self.metasettings = {
            "socket_name": {
                "description": "Socket file name, inside the Nicotine+ data folder:",
                "type": "string"
            },
            "download_root": {
                "description": "Folder every download requested over the socket lands under:",
                "type": "string"
            },
        }

        self.searches = {}
        self.lock = threading.Lock()
        self.server = None
        self.socket_path = None

    # Lifecycle #

    def loaded_notification(self):

        # First in line: core.search clears msg.token on responses to searches
        # it does not know, and ours are unknown to it by design.
        events._callbacks["file-search-response"].insert(0, self._file_search_response)  # pylint: disable=protected-access

        self.socket_path = os.path.join(self.config.data_folder_path, self.settings["socket_name"])

        try:
            os.unlink(self.socket_path)
        except FileNotFoundError:
            pass

        plugin = self

        class Handler(socketserver.StreamRequestHandler):
            def handle(self):
                plugin.handle_connection(self.rfile, self.wfile)

        class Server(socketserver.ThreadingMixIn, socketserver.UnixStreamServer):
            daemon_threads = True

        self.server = Server(self.socket_path, Handler)
        os.chmod(self.socket_path, 0o600)
        threading.Thread(target=self.server.serve_forever, name="AgentApi", daemon=True).start()

        self.log("Listening on %s", self.socket_path)

    def disable(self):

        events.disconnect("file-search-response", self._file_search_response)

        for token in list(self.searches):
            self._search_close(token)

        if self.server is not None:
            self.server.shutdown()
            self.server.server_close()
            self.server = None

        try:
            os.unlink(self.socket_path)
        except (FileNotFoundError, TypeError):
            pass

    def shutdown_notification(self):
        self.disable()

    # Socket side (server threads) #

    def handle_connection(self, rfile, wfile):

        try:
            request = json.loads(rfile.readline().decode("utf-8"))
            command = getattr(self, "cmd_" + str(request.pop("cmd", "")).replace("-", "_"), None)

            if command is None:
                raise ValueError("unknown cmd")

            reply = {"ok": True, "result": command(**request)}

        except Exception as error:  # pylint: disable=broad-except
            reply = {"ok": False, "error": f"{type(error).__name__}: {error}"}

        try:
            wfile.write(json.dumps(reply, ensure_ascii=False).encode("utf-8") + b"\n")
        except OSError:
            pass

    def _main(self, function, *args):
        """Run function on Nicotine+'s main thread, where all of core lives."""

        done = threading.Event()
        box = {}

        def run():
            try:
                box["result"] = function(*args)
            except Exception as error:  # pylint: disable=broad-except
                box["error"] = error
            finally:
                done.set()

        events.invoke_main_thread(run)

        if not done.wait(MAIN_THREAD_TIMEOUT):
            raise TimeoutError("Nicotine+ main thread did not answer")

        if "error" in box:
            raise box["error"]

        return box["result"]

    # Commands #

    def cmd_status(self):

        def status():
            users = self.core.users
            downloads = self.core.downloads.transfers.values()

            return {
                "online": users.login_status != UserStatus.OFFLINE,
                "username": users.login_username,
                "download_root": self.settings["download_root"],
                "downloads": len(downloads),
                "active": sum(1 for t in downloads if t.status == "Transferring"),
            }

        result = self._main(status)
        result["searches"] = len(self.searches)
        return result

    def cmd_search(self, term):

        def search():
            if self.core.users.login_status == UserStatus.OFFLINE:
                raise RuntimeError("not logged in to the Soulseek server")

            _sanitized, transmitted, _included, _excluded = self.core.search.sanitize_search_term(term)

            if not transmitted:
                raise ValueError("search term is empty after sanitizing")

            self._expire_searches()

            self.core.search.token = token = increment_token(self.core.search.token)
            self.searches[token] = {"term": transmitted, "started": time.time(), "files": 0, "responses": []}
            self.core.search.add_allowed_token(token)
            self.core.send_message_to_server(FileSearch(token, transmitted))

            return {"token": token, "term": transmitted}

        return self._main(search)

    def cmd_results(self, token):

        with self.lock:
            search = self.searches.get(int(token))

            if search is None:
                raise KeyError("no such search (they expire after 15 minutes)")

            return {
                "term": search["term"],
                "age": round(time.time() - search["started"], 1),
                "responses": list(search["responses"]),
            }

    def cmd_search_close(self, token):
        self._main(self._search_close, int(token))

    def cmd_download(self, user, job, folder=None, files=()):
        """Queue files ([path, size, attributes]) from one user into
        download_root/job. With `folder`, the user is also asked for the
        whole folder, which adds what the search did not show (cover, log,
        cue), and the folder's own structure is kept below it."""

        destination = self._job_path(job)

        def download():
            downloads = self.core.downloads

            if folder:
                downloads.enqueue_folder(user, folder, download_folder_path=destination)

            for path, size, attributes in files:
                if folder and path.startswith(folder.rstrip("\\") + "\\"):
                    target = downloads.get_folder_destination(
                        user, path.rpartition("\\")[0], root_folder_path=folder, download_folder_path=destination)
                else:
                    target = destination

                downloads.enqueue_download(
                    user, path, folder_path=target, size=size,
                    file_attributes={int(key): value for key, value in (attributes or {}).items()})

            return {"destination": destination, "queued": len(files)}

        return self._main(download)

    def cmd_transfers(self, job=None, user=None):
        return self._main(lambda: [self._transfer_info(t) for t in self._select(job, user)])

    def cmd_retry(self, job=None, user=None):
        return self._act(job, user, lambda downloads: [self.core.downloads.retry_download(t) for t in downloads])

    def cmd_abort(self, job=None, user=None):
        return self._act(job, user, lambda downloads: self.core.downloads.abort_downloads(downloads))

    def cmd_clear(self, job=None, user=None):
        """Abort and forget. Files already on disk stay there."""

        def clear(downloads):
            self.core.downloads.abort_downloads(downloads)
            self.core.downloads.clear_downloads(downloads)

        return self._act(job, user, clear)

    # Main thread helpers #

    def _act(self, job, user, action):

        if not job and not user:
            raise ValueError("give a job or a user, this never acts on every download")

        def act():
            downloads = self._select(job, user)
            action(downloads)
            return {"transfers": len(downloads)}

        return self._main(act)

    def _job_path(self, job):

        job = str(job)

        if not job or job in {".", ".."} or "/" in job or "\\" in job or "\0" in job:
            raise ValueError("job must be a plain folder name")

        return os.path.join(self.settings["download_root"], job)

    def _select(self, job, user):

        root = self._job_path(job) if job else self.settings["download_root"]

        return [
            transfer for transfer in self.core.downloads.transfers.values()
            if (transfer.folder_path == root or str(transfer.folder_path).startswith(root + os.sep))
            and (not user or transfer.username == user)
        ]

    @staticmethod
    def _transfer_info(transfer):
        return {
            "user": transfer.username,
            "path": transfer.virtual_path,
            "folder": transfer.folder_path,
            "size": transfer.size,
            "offset": transfer.current_byte_offset or 0,
            "status": transfer.status,
            "speed": transfer.speed or 0,
            "queue": transfer.queue_position or 0,
        }

    def _search_close(self, token):

        self.core.search.remove_allowed_token(token)

        with self.lock:
            self.searches.pop(token, None)

    def _expire_searches(self):

        now = time.time()

        for token, search in list(self.searches.items()):
            if now - search["started"] > SEARCH_TTL:
                self._search_close(token)

    def _file_search_response(self, msg):

        search = self.searches.get(msg.token)

        if search is None:
            return

        username = msg.username
        ip_address, _port = msg.addr

        if (self.core.network_filter.is_user_ignored(username)
                or self.core.network_filter.is_user_ip_ignored(username, ip_address)):
            return

        response = {
            "user": username,
            "free": bool(msg.freeulslots),
            "speed": msg.ulspeed or 0,
            "queue": msg.inqueue or 0,
            "locked": len(msg.privatelist or ()),
            "files": [[path, size, attributes] for _code, path, size, _ext, attributes, *_unused in msg.list],
        }

        with self.lock:
            search["responses"].append(response)
            search["files"] += len(response["files"])

        if search["files"] >= SEARCH_MAX_FILES:
            self.core.search.remove_allowed_token(msg.token)
