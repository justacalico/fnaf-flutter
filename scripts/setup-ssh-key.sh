#!/bin/sh
set -eu
KEY_VAR="${1:-}"
HOST="${2:-}"
if [ -z "$KEY_VAR" ] || [ -z "$HOST" ]; then
  echo "Usage: $0 <env-var-name> <ssh-host>" >&2
  exit 1
fi
KEY_VALUE=$(eval "printf '%s' \"\${$KEY_VAR:-}\"")
if [ -z "$KEY_VALUE" ]; then
  echo "$KEY_VAR is not set, skipping SSH key setup" >&2
  exit 0
fi
mkdir -p ~/.ssh && chmod 700 ~/.ssh
TMP=~/.ssh/id_ed25519.tmp
if [ -f "$KEY_VALUE" ]; then cp "$KEY_VALUE" "$TMP"; else printf '%s\n' "$KEY_VALUE" > "$TMP"; fi
sed 's/\\n/\n/g' "$TMP" | tr -d '\r' > ~/.ssh/id_ed25519
rm -f "$TMP"
printf '\n' >> ~/.ssh/id_ed25519
chmod 600 ~/.ssh/id_ed25519
ssh-keygen -y -f ~/.ssh/id_ed25519 >/dev/null 2>&1 || { echo "ERROR: $KEY_VAR not loadable" >&2; exit 1; }
ssh-keyscan -t ed25519 "$HOST" > ~/.ssh/known_hosts
