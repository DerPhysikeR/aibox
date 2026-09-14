#!/usr/bin/env bash
set -euo pipefail

global_config=~/.config/aibox
global_qcow=$(tail --lines 1 "$global_config/qcowpath")

project=$(git rev-parse --show-toplevel)
local_config=$project/.aibox
mkdir -p "$local_config"
local_qcow=$local_config/aibox.qcow2
[ -e "$local_qcow" ] || {
    cp --reflink=auto "$global_qcow" "$local_qcow"
    chmod u+w "$local_qcow"
}

up() {
    echo "Starting AI box..."

    # -display none -> no GUI
    # -nographic -> serial console directly without ssh

    qemu-system-x86_64 \
      -accel kvm \
      -daemonize \
      -cpu host \
      -display none \
      -m 4G \
      -smp 2 \
      -drive file="$local_qcow",format=qcow2,if=virtio \
      -nic user,model=virtio,hostfwd=tcp::2222-:22
}

connect() {
    ssh -p 2222 \
      -o StrictHostKeyChecking=no \
      -o UserKnownHostsFile=/dev/null \
      -o ConnectTimeout=30 \
      agent@localhost
}

usage() {
    echo "Usage: aibox {up|connect}"
}

case "${1:-}" in
    up)
        up
        ;;
    connect)
        connect
        ;;
    *)
        usage
        exit 1
        ;;
esac
