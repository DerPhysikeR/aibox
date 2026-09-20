#!/usr/bin/env bash
set -euo pipefail

global_config=~/.config/aibox
global_qcow=$(tail --lines 1 "$global_config/qcowpath")
project=$(git rev-parse --show-toplevel)
name=$(basename "$project")
local_config=$project/.aibox
local_qcow=$local_config/aibox.qcow2
local_tinyproxy=$local_config/tinyproxy.conf
ssh_port=$(cat "$local_config/ssh_port" 2>/dev/null || echo 2222)
proxy_port=$(cat "$local_config/proxy_port" 2>/dev/null || echo 8888)
ssh_opts="-p ${ssh_port} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=30"

init() {
    mkdir -p "$local_config"
    [ -e "$local_qcow" ] || {
        cp --reflink=auto "$global_qcow" "$local_qcow"
        chmod u+w "$local_qcow"
    }
    ssh_port=$(shuf -i 1025-65536 -n 1)
    proxy_port=$(shuf -i 1025-65536 -n 1)
    echo $ssh_port > "$local_config/ssh_port"
    echo $proxy_port > "$local_config/proxy_port"
    AIBOX_DIR="$local_config" AIBOX_PORT="$proxy_port" envsubst < "$global_config/tinyproxy.conf" > "$local_tinyproxy"
    cp "$global_config/tinyproxy.whitelist" "$local_config"
}

up() {
    echo "Starting AI box..."

    # -display none -> no GUI
    # -nographic -> serial console directly without ssh

    tinyproxy -c "$local_tinyproxy"

    qemu-system-x86_64 \
      -accel kvm \
      -daemonize \
      -cpu host \
      -display none \
      -m 4G \
      -smp 2 \
      -drive file="$local_qcow",format=qcow2,if=virtio \
      -nic "user,model=virtio,hostfwd=tcp::${ssh_port}-:22,restrict=on,guestfwd=tcp:10.0.2.100:8888-cmd:nc 127.0.0.1 ${proxy_port}"
}

connect() {
   rsync -avL \
       --delete \
       --mkpath \
       -e "ssh $ssh_opts" \
       "$HOME/.config/tmux/" \
       "agent@localhost:.config/tmux/"
   ssh $ssh_opts agent@localhost \
       "./.config/tmux/plugins/tpm/bin/install_plugins"
   rsync -av \
       --delete \
       --mkpath \
       -e "ssh $ssh_opts" \
       "$HOME/.config/nvim/" \
       "agent@localhost:.config/nvim/"
    ssh $ssh_opts agent@localhost
}

repoinit() {
    local remote_url="ssh://agent@localhost:${ssh_port}/home/agent/.remotes/$name.git"

    ssh $ssh_opts agent@localhost \
        "mkdir -p ~/.remotes && git init --bare --initial-branch=main ~/.remotes/${name}.git"
    git remote set-url aibox "$remote_url" 2>/dev/null || git remote add aibox "$remote_url"
    git push aibox main
    ssh $ssh_opts agent@localhost \
        "cd ~ && git clone ~/.remotes/${name}.git $name"
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
