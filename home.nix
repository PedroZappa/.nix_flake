# man home-configuration.nix
{
  config,
  pkgs,
  lib,
  ...
}: {
  home.username = "zedro";
  home.homeDirectory = "/home/zedro";
  home.stateVersion = "24.11"; # Please read the release notes before changing.
  home.extraActivationPath = with pkgs; [
    git # Get .dotfiles
    openssh # Get .dotfiles
    zsh # Get zsh to then get zap
    curl # Get zap, zsh Pckage manager
    uv # Get python apps (postings)
  ];
  # The home.packages option allows you to install Nix packages into your env.
  home.packages = with pkgs; [
    jq # CLI for working with JSON
    # All that silly shit
    dwt1-shell-color-scripts # Scripts to look good
    fastfetch # Sys Info Fetcher
    clolcat # lol
    htop # sys Monitor
    eza # Colourful ls

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
  home.file = {};

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

  # ************************************************************************** //
  #                             Activation Scripts                             //
  # ************************************************************************** //

  # Activation script to set up SSH key and clone dotfiles repository
  home.activation.cloneDotfiles = lib.mkAfter ''
    # Define SSH key path
    SSH_KEY="$HOME/.ssh/id_ed25519"
    DOTFILES="git@github.com:PedroZappa/.dotfiles.git"

    # Check if SSH key exists
    if [ ! -f "$SSH_KEY" ]; then
      echo "No SSH key found. Generating a new SSH key..."

      # Generate a new SSH key
      ssh-keygen -t ed25519 -C "[email protected]" -f "$SSH_KEY" -N ""

      # Start the ssh-agent and add the new key
      eval "$(ssh-agent -s)"
      ssh-add "$SSH_KEY"

      # Extract the public key
      PUB_KEY=$(cat "$SSH_KEY.pub")

      # Prompt user for GitHub username and personal access token
      echo "Please enter your GitHub username:"
      read -r GITHUB_USER
      echo "Please enter your GitHub personal access token:"
      read -rs GITHUB_TOKEN

      # Add the SSH key to the user's GitHub account
      echo "Adding the SSH key to your GitHub account..."
      curl -u "$GITHUB_USER:$GITHUB_TOKEN" \
        --data "{\"title\":\"$(hostname) - $(date)\",\"key\":\"$PUB_KEY\"}" \
        https://api.github.com/user/keys

      echo "SSH key added successfully."
    else
      echo "SSH key already exists."
    fi

    # Clone the dotfiles repository if it doesn't exist
    if [ ! -d "$HOME/.dotfiles" ]; then
      echo "Cloning dotfiles repository..."
      git clone $DOTFILES "$HOME/.dotfiles"
      echo "Dotfiles repository cloned successfully."
    else
      echo "Dotfiles repository already exists."
    fi

    echo "Creating .dotfiles symlinks..."
    # bash .$HOME/.nix_flake/scripts/dotfiles_symlinks.sh
  '';

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
    gnome-shell = {enable = true;};
    starship = {enable = true;};
    tmux = {enable = true;};
    # neovim = {
    #   enable = true;
    #   extraPackages = with pkgs; [
    #     clang
    #     clang-tools
    #   ];
    #   plugins = with pkgs.vimPlugins; [
    #     nvim-lspconfig
    #   ];
    #   extraLuaConfig = ''
    #     local nvim_lsp = require'lspconfig'
    #     nvim_lsp.clangd.setup {
    #       cmd = { "${pkgs.clang-tools}/bin/clangd", "--query-driver=${pkgs.gcc}/bin/g++" }
    #     }
    #   '';
    # };
  };
}
