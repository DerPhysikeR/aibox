#!/bin/env bash
set -euo pipefail

config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/aibox"

mkdir -p "${config_dir}"
ln -s --force --no-dereference "$(realpath aibox.sh)" "${HOME}/.local/bin/aibox"
cp tinyproxy.conf "${config_dir}"
cp tinyproxy.whitelist "${config_dir}"
touch "${config_dir}/qcowpath"
