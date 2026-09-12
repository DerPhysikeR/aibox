FROM docker.io/library/archlinux:latest

# Base environment -- changes rarely.
RUN pacman -Syu --noconfirm \
    git \
    nix \
    sudo \
    && pacman -Scc --noconfirm

# Add whatever you want below here.
RUN pacman -S --noconfirm \
    tmux \
    ripgrep \
    fd \
    jq \
    neovim

RUN pacman -S --noconfirm \
    opencode

WORKDIR /work

CMD ["/bin/bash"]
