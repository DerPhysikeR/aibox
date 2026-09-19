#!/usr/bin/env bash
set -euo pipefail

qcow_out=$(
  nix build .#nixosConfigurations.agent.config.system.build.qcow2 \
    --no-link \
    --print-out-paths
)

touch ~/.config/aibox/qcowpath
echo "$qcow_out/nixos.qcow2" >> ~/.config/aibox/qcowpath
