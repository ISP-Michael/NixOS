#!/usr/bin/env bash
# Print the public age recipient of this machine's SSH host key.
set -euo pipefail
ssh-to-age -i /etc/ssh/ssh_host_ed25519_key.pub
