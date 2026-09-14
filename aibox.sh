#!/usr/bin/env bash
set -euo pipefail

global_config=~/.config/aibox
global_qcow=$(tail --lines 1 "$global_config/qcowpath")
project=$(git rev-parse --show-toplevel)
name=$(basename "$project")
local_config=$project/.aibox
local_qcow=$local_config/aibox.qcow2

init() {
    mkdir -p "$local_config"
    [ -e "$local_qcow" ] || {
        cp --reflink=auto "$global_qcow" "$local_qcow"
        chmod u+w "$local_qcow"
    }
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

repoinit() {
    rsync -av \
        --mkpath \
        -e "ssh -p 2222 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=30" \
        "$project/.git" \
        "agent@localhost:~/$name"
    ssh -p 2222 \
      -o StrictHostKeyChecking=no \
      -o UserKnownHostsFile=/dev/null \
      agent@localhost \
      "cd ~/$name && git reset --hard HEAD"
    git remote add aibox "ssh://agent@localhost:2222/home/agent/$name"
}

usage() {
    echo "Usage: aibox {init|up|connect|repoinit}"
}

case "${1:-}" in
    init)
        init
        ;;
    up)
        up
        ;;
    connect)
        connect
        ;;
    repoinit)
        repoinit
        ;;
    *)
        usage
        exit 1
        ;;
esac
