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
    ranger \
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

RUN mkdir -p /etc/opencode
RUN cat > /etc/opencode/opencode.json <<'EOF'
{
  "$schema": "https://opencode.ai/config.json",

  "agent": {
    "build": {
      "model": "github-copilot/gpt-5-mini"
    },
    "plan": {
      "model": "github-copilot/claude-sonnet-5"
    }
  }
}
EOF

# Startup
USER agent
WORKDIR /work
CMD ["zsh"]
