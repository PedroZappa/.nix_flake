# man home-configuration.nix

{ config, pkgs, lib, ... }:

{
  home.username = "zedro";
  home.homeDirectory = "/home/zedro";
  home.stateVersion = "24.11"; # Please read the release notes before changing.
  # Ensure 'uv' is available during activation
  home.extraActivationPath = [ pkgs.uv ];
  # The home.packages option allows you to install Nix packages into your env.
  home.packages = with pkgs; [
    git
    curl
    # All that silly shit
    dwt1-shell-color-scripts # Scripts to look good
    fastfetch # Sys Info Fetcher
    clolcat   # lol 
    htop      # sys Monitor
    eza       # Colourful ls

    # (pkgs.nerdfonts.override { fonts = [ "FiraCode" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    (pkgs.writeShellScriptBin "my-hello" ''
      echo "Hello, ${config.home.username}!"
    '')
  ];

  # Home Manager is pretty good at managing dotfileS. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/zedro/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    HM_TEST_VAR = "Y0 Z3dr0 m1 dud3!!!";
    EDITOR = "nvim";
    PAGER = "bat";
  };

  # Activation script to install oh-my-tmux if not already installed
  home.activation.installOhMyTmux = lib.mkAfter ''
    if [ ! -d "$HOME/.tmux" ] || [ ! -L "$HOME/.tmux.conf" ]; then
      echo "Installing oh-my-tmux..."
      git clone https://github.com/gpakosz/.tmux.git "$HOME/.tmux"
      ln -s -f "$HOME/.tmux/.tmux.conf" "$HOME/.tmux.conf"
      cp "$HOME/.tmux/.tmux.conf.local" "$HOME/.tmux.conf.local"
      echo "oh-my-tmux installation complete."
    else
      echo "oh-my-tmux is already installed."
    fi
  '';

  # Activation script to install Zap if not already installed
  home.activation.installZap = lib.mkAfter ''
    if [ ! -d "$HOME/.local/share/zap" ]; then
      echo "Installing Zap: zsh's Package Manager..."
      zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh) --branch release-v1
      echo "Zap installation complete. 🤙"
    else
      echo "Zap is already installed."
    fi
  '';

  # Activation script to install posting (if not already installed)
  home.activation.installPosting = lib.mkAfter ''
    if ! command -v posting >/dev/null 2>&1; then
      echo "Posting not found – installing via uv tool..."
      uv tool install --python 3.12 posting
    else
      echo "Posting already installed."
    fi
  '';

  # Let Home Manager install and manage itself.
  programs = { 
    home-manager.enable = true;
    # Gnome Shell
    gnome-shell = {
      enable = true;
    };
    tmux = {
      enable = true;
    };
    neovim = {
      enable = true;
    };
    starship = {
      enable = true;
    };
  };
}

