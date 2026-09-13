#!/bin/sh

# Update inputs when you deliberately want newer packages
nix flake update

# Build fresh immutable VM image
nix build .#nixosConfigurations.agent.config.system.build.qcow2
