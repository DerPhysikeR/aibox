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
    -f "$HOME/.config/aibox/Containerfile" \
    "$HOME/.config/aibox"

exec podman run --rm -it \
    --name "$name" \
    --read-only \
    --cap-drop=ALL \
    --security-opt=no-new-privileges \
    --userns=keep-id \
    --tmpfs /tmp \
    --tmpfs /run \
    --network=none \
    -v "$dir:/work:rw,Z" \
    -w /work \
    aibox
