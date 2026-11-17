#!/bin/sh
# Copy the given paths to the system clipboard as file:// URIs.
# Directories are skipped: they cannot be attached as files.
python3 -c '
import pathlib, sys
out = []
for arg in sys.argv[1:]:
    p = pathlib.Path(arg)
    if p.is_file():
        out.append(p.as_uri() + "\r\n")
sys.stdout.write("".join(out))
' "$@" | wl-copy --type text/uri-list
