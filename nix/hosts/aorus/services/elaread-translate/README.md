# elaread-translate on another host

The translation relay for the Elaread app (an Android reader for web novels), packaged for a host other than evictus — here **daorus**, as the backup server. The phone posts a chapter's paragraphs to `:8787/translate`, the relay runs `claude -p` and returns the translation as JSON. The app tries its main server first and switches to the backup when the main one doesn't answer (Settings → Translation → "Backup server").

`elaread-translate.py` is the same file that evictus runs from dotfiles (`nix/modules/user/server/`); only its environment differs.

## What it needs

- Linux with systemd and **Python ≥ 3.8** (standard library only).
- **Claude Code** (`claude`) **≥ 2.1**, logged in to a Claude subscription — either a token or an existing login, see below.
- **Tailscale** on the same tailnet as the phone; the relay listens on the host's tailnet address only.

## Install (any Linux)

```sh
# 1. Claude Code where any user can run it (the service runs as a user of its own):
sudo npm install -g @anthropic-ai/claude-code      # → /usr/local/bin/claude (or /usr/bin/claude)
claude --version

# 2. The relay and its unit:
sudo install -Dm644 elaread-translate.py /opt/elaread-translate/elaread-translate.py
sudo install -Dm644 elaread-translate.service /etc/systemd/system/elaread-translate.service

# 3. Settings: check ELAREAD_CLAUDE (`command -v claude`) and ELAREAD_LISTEN (`tailscale ip -4`).
sudo install -Dm600 elaread-translate.env.example /etc/elaread-translate.env
sudoedit /etc/elaread-translate.env

# 4. Claude's login — a long-lived token (opens a browser; any machine will do):
claude setup-token
#    and put it into /etc/elaread-translate.env as CLAUDE_CODE_OAUTH_TOKEN=…

# 5. Start:
sudo systemctl daemon-reload
sudo systemctl enable --now elaread-translate
journalctl -u elaread-translate -f       # "listening on 100.91.220.75:8787, allowing [...]"
```

If `python3` isn't `/usr/bin/python3`, fix `ExecStart=` in the unit.

### An existing login instead of a token

If a user of the host is already logged in to Claude Code, the service can run as that user and use their `~/.claude`. Leave `CLAUDE_CODE_OAUTH_TOKEN` empty and add a drop-in (`sudo systemctl edit elaread-translate`):

```ini
[Service]
DynamicUser=no
User=<that user>
Environment=HOME=/home/<that user>
# claude rewrites ~/.claude.json and its credentials in place.
ProtectHome=no
ReadWritePaths=/home/<that user>
```

`ELAREAD_CLAUDE` may then point at that user's own `claude` (e.g. `~/.local/bin/claude`).

## Install (NixOS)

Copy this directory next to `configuration.nix` (or into the flake) and add:

```nix
{ lib, ... }: {
	imports = [ ./elaread-translate/nixos.nix ];
	services.elaread-translate = {
		enable = true;
		# A user already logged in to Claude Code: the relay runs as them, with their ~/.claude.
		user = "<that user>";
		# listen = "100.91.220.75:8787";   # the default: this host's tailnet address
	};
	nixpkgs.config.allowUnfreePredicate = p: builtins.elem (lib.getName p) [ "claude-code" ];
}
```

then `sudo nixos-rebuild switch`. Port 8787 opens on `tailscale0` only (`openFirewall`, on by default). Without `user` the relay runs as a throwaway user and needs a token instead: `CLAUDE_CODE_OAUTH_TOKEN=…` from `claude setup-token` in `/etc/elaread-translate.env` (`chmod 600`).

## Firewall and tailnet

- A host firewall must let **TCP 8787 in on `tailscale0`**, e.g. `sudo ufw allow in on tailscale0 to any port 8787 proto tcp`, or `sudo firewall-cmd --zone=trusted --add-interface=tailscale0 --permanent` (firewalld), or on NixOS `networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 8787 ];`.
- If the tailnet's ACLs limit who reaches this host, the phone (`eparadigm`, 100.67.0.2) needs `:8787`.
- The relay answers only the addresses in `ELAREAD_ALLOW` (403 for anyone else): WireGuard ties a source address to its peer's key, so another node can't pretend to be the phone.

## Check

```sh
curl -s http://100.91.220.75:8787/health              # from an allowed node, e.g. evictus → {"ok": true}
curl -s http://100.91.220.75:8787/translate -H 'Content-Type: application/json' \
	-d '{"src":"en","tgt":"uk","model":"haiku","effort":"low","items":["Hello, world."]}'
```

`{"t": ["Привіт, світе."]}` means it works. An `{"error": "claude: Not logged in…"}` or `"…401 OAuth access token is invalid"` is the login; `403 not an own tailnet node` is `ELAREAD_ALLOW`. In the app: Settings → Translation → "Check" asks both servers.

## Safety

- `claude` runs with no tools, no MCP and no settings (`--tools "" --strict-mcp-config --setting-sources ""`): a chapter's text can only come back as text.
- The unit runs as a throwaway user (`DynamicUser`) that sees nothing but its own `/var/lib/elaread-translate` and the network.
- The token gives full use of the subscription it came from: keep the env file `600 root`.

## Update

Copy the new `elaread-translate.py` over `/opt/elaread-translate/` and `sudo systemctl restart elaread-translate`.
