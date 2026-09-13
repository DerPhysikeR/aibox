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
chmod u+w "$local_qcow"

# -display none -> no GUI
# -nographic -> serial console directly without ssh

qemu-system-x86_64 \
  -accel kvm \
  -cpu host \
  -display none \
  -m 4G \
  -smp 2 \
  -drive file="$local_qcow",format=qcow2,if=virtio \
  -nic user,model=virtio,hostfwd=tcp::2222-:22 \
  &

qemu_pid=$!

cleanup() {
    kill "$qemu_pid" 2>/dev/null || true
    wait "$qemu_pid" 2>/dev/null || true
}

trap cleanup EXIT

sleep 1

ssh -p 2222 \
  -o StrictHostKeyChecking=no \
  -o ConnectTimeout=30 \
  agent@localhost
