FROM docker.io/library/archlinux:latest

# Stuff that needs network access
## Base system
RUN pacman -Syu --noconfirm \
    git \
    nix \
    sudo \
    && pacman -Scc --noconfirm

## Shell setup
RUN pacman -Syu --noconfirm \
    zsh \
    zsh-completions \
    starship \
    tmux \
    ripgrep \
    fd \
    jq \
    && pacman -Scc --noconfirm

## Coding tools
RUN pacman -Syu --noconfirm \
    neovim \
    opencode \
    && pacman -Scc --noconfirm

# Local configuration
## user setup
ARG UID=1000
ARG GID=1000
RUN groupadd -g $GID -o agent
RUN useradd -m -u $UID -g $GID -s /bin/zsh agent

ENV ZDOTDIR=/etc/zsh/zshrc
RUN cat > /etc/zsh/zshrc <<'EOF'
autoload -Uz compinit
compinit
eval "$(starship init zsh)"
EOF

# Startup
USER agent
WORKDIR /work
CMD ["zsh"]
