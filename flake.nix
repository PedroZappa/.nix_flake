{
  description = "Flake that builds my desktop and VM";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager?ref=release-24.11";
      inputs.nixpkgs.follows = "nixpkgs"; # Use nixpkgs
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      # If you are not running an unstable channel of nixpkgs, select the corresponding branch of nixvim.
      # url = "github:nix-community/nixvim/nixos-24.11";

      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    home-manager,
    nixvim,
  }: let
    # Variables Used In Flake
    system = "x86_64-linux";
    vars = {
      user = "zedro";
      location = "$HOME/.nix_flake";
      terminal = "ghostty";
      editor = "nvim";
    };

    # System Specific ettings
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  in {
    # Desktop Config
    nixosConfigurations = {
      znix = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit inputs;};
        modules = [
          ./hosts/znix/configuration.nix
          # ./hosts/znix/hardware-configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {inherit vars;};
            home-manager.users.${vars.user} = import ./home.nix;
          }
        ];
      };
    };

    # VM configuration
    nixvm = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        inherit inputs;
        hostname = "nixvm";
      };
      modules = [
        ./hosts/nixvm/configuration.nix
        ./hosts/nixvm/hardware-configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = {inherit vars;};
          home-manager.users.${vars.user} = import ./home.nix;
        }
      ];
    };
  };
}
