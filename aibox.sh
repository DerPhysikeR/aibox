#!/usr/bin/env bash
set -euo pipefail

root="$(git rev-parse --show-toplevel)"
name="aibox-$(date +%Y%m%d-%H%M%S)"
dir="$HOME/.local/share/aibox/$name"

mkdir -p "$dir"
cp -a "$root/." "$dir/"

git -C "$root" remote add "$name" "$dir"

podman build \
    -t aibox \
    --build-arg GID=$(id -g) \
    --build-arg UID=$(id -u) \
    -f "$HOME/.config/aibox/Containerfile" \
    "$HOME/.config/aibox"

exec podman run --rm -it \
    --name "$name" \
    --read-only \
    --cap-drop=ALL \
    --security-opt=no-new-privileges \
    --userns=keep-id \
    --tmpfs /tmp:rw \
    --tmpfs /run:rw \
    --user agent \
    --mount type=tmpfs,destination=/home/agent,U=true,tmpfs-mode=0700 \
    -e HOME=/home/agent \
    -e OPENCODE_CONFIG=/etc/opencode/opencode.json \
    -e GITHUB_TOKEN=$(gopass show -o personal/tokens/github-opencode) \
    -v "$dir:/work:rw,Z" \
    -w /work \
    aibox
