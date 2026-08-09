#!/bin/sh
# Xpra needs a private, 0700 XDG_RUNTIME_DIR for its sockets; create it at run
# time (a build-time /run dir would be shadowed by podman's tmpfs on /run).
set -e
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp/xpra-runtime}"
mkdir -p "$XDG_RUNTIME_DIR"
chmod 700 "$XDG_RUNTIME_DIR"
exec "$@"
