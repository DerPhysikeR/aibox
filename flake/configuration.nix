{ config, pkgs, lib, llm-agents, ... }:

{
  networking.hostName = "agent";

  # Nix is already part of NixOS. We only need to enable the modern CLI
  # and flakes.
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # ---------------------------------------------------------------------------
  # User
  # ---------------------------------------------------------------------------

  users.users.agent = {
    isNormalUser = true;
    description = "AI agent";
    shell = pkgs.zsh;

    # Allows sudo.
    extraGroups = [
      "wheel"
    ];

    # Replace this with your actual public key.
    openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDXNvziLL1UxkbwWlm+ZcskAJvNtGN1viwkuG2ZEYMYE paul@workpad"
    ];
  };

  # Since this machine is deliberately disposable, passwordless sudo inside
  # the VM is reasonable. The isolation boundary is the VM, not sudo.
  security.sudo.wheelNeedsPassword = false;

  # ---------------------------------------------------------------------------
  # SSH
  # ---------------------------------------------------------------------------

  services.openssh = {
    enable = true;

    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  # SSH is automatically handled appropriately by the NixOS firewall when
  # services.openssh is enabled.
  networking.firewall.enable = true;

  # ---------------------------------------------------------------------------
  # Shell
  # ---------------------------------------------------------------------------

  programs.nix-ld.enable = true;
  programs.yazi.enable = true;
  programs.zsh.enable = true;

  programs.starship = {
    enable = true;
  };

  # ---------------------------------------------------------------------------
  # Hide zsh setup dialog
  # ---------------------------------------------------------------------------

  system.userActivationScripts.zshrc = ''
    touch "$HOME/.zshrc"
  '';

  # ---------------------------------------------------------------------------
  # Containers
  # ---------------------------------------------------------------------------

  virtualisation.podman = {
    enable = true;

    # Optional. Handy because agents frequently assume `docker` exists.
    dockerCompat = true;

    defaultNetwork.settings.dns_enabled = true;
  };

  # ---------------------------------------------------------------------------
  # Tools
  # ---------------------------------------------------------------------------

  environment.systemPackages = with pkgs; [
    # Base
    git
    sudo

    # Shell / CLI
    zsh
    zsh-completions
    starship
    tmux
    ripgrep
    fd
    jq
    ranger
    htop
    fzf

    # Container tooling
    podman

    # Editors / coding agents
    neovim
    opencode
    llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.pi

    # Development environments
    devenv

    # Things I would add for an agent VM even though they weren't explicitly
    # in the original Containerfile.
    curl
    wget
    rsync
    tree
    file
    unzip
    zip
    less
    which
  ];

  # ---------------------------------------------------------------------------
  # OpenCode
  # ---------------------------------------------------------------------------

  environment.etc."opencode/opencode.json".text = ''
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
  '';

  # ---------------------------------------------------------------------------
  # zsh defaults
  # ---------------------------------------------------------------------------

  environment.etc."zsh/zshrc.local".text = ''
    autoload -Uz compinit
    compinit

    eval "$(starship init zsh)"
  '';

  # Have the global zsh config source our small local config.
  programs.zsh.interactiveShellInit = ''
    source /etc/zsh/zshrc.local
  '';

  # ---------------------------------------------------------------------------
  # VM basics
  # ---------------------------------------------------------------------------

  # DHCP should be sufficient when attached to a normal libvirt NAT network.
  networking.useDHCP = lib.mkDefault true;

  networking.proxy = {
    default = "http://10.0.2.100:8888";
    noProxy = "127.0.0.1,localhost,::1";
  };

  # Compatibility with programs that only check uppercase variants.
  environment.variables = {
    HTTP_PROXY  = "http://10.0.2.100:8888";
    HTTPS_PROXY = "http://10.0.2.100:8888";
    NO_PROXY    = "127.0.0.1,localhost,::1";
  };

  # No desktop environment, display manager, X11, etc.
  # NixOS is headless unless you explicitly configure those things.

  # Required by NixOS configurations.
  #
  # This is *not* the NixOS release you are currently using. It controls
  # compatibility defaults and should normally stay fixed after creation.
  system.stateVersion = "26.05";
}
