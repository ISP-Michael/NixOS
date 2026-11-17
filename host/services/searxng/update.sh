#!/bin/sh
set -eu

IMAGE="searxng/searxng:latest"
CONTAINER="searxng"
SERVICE="docker-searxng.service"
HEALTH_URL="http://127.0.0.1:8888/search?q=health&format=json"
STATE_DIR="${STATE_DIRECTORY:-/var/lib/searxng-update}"
PREV="$STATE_DIR/previous-image"

mkdir -p "$STATE_DIR"

current="$(docker inspect --format '{{.Image}}' "$CONTAINER" 2>/dev/null || true)"
echo "current: ${current:-<none>}"

if ! docker pull "$IMAGE" >/dev/null 2>&1; then
  echo "pull failed, keeping current image"
  exit 0
fi

new="$(docker image inspect --format '{{.Id}}' "$IMAGE")"
echo "latest:  $new"

if [ "$current" = "$new" ]; then
  echo "already up to date"
  exit 0
fi

printf '%s\n' "$current" > "$PREV"
systemctl restart "$SERVICE"

i=0
while [ "$i" -lt 30 ]; do
  if curl -fsS -m 5 "$HEALTH_URL" >/dev/null 2>&1; then
    echo "updated OK: $new"
    exit 0
  fi
  i=$((i + 1))
  sleep 2
done

echo "healthcheck failed, rolling back"
if [ -n "$current" ]; then
  docker tag "$current" "$IMAGE"
  systemctl restart "$SERVICE"
  echo "rolled back to $current"
else
  echo "no previous image, leaving as is"
fi
exit 1
