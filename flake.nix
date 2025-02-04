{
  description = "Your new nix config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # nix-darwin
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # tokyonight ressources
    tokyonight = {
      url = "github:folke/tokyonight.nvim";
      flake = false;
    };
  };

  outputs =
    inputs@{ self
    , nixpkgs
    , darwin
    , home-manager
    , tokyonight
    , ...
    }:
    let
      darwinSystems = [ "aarch64-darwin" "x86_64-darwin" ];
      linuxSystems = [ "aarch64-linux" "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs (darwinSystems ++ linuxSystems);
      forDarwinSystems = nixpkgs.lib.genAttrs darwinSystems;
      forLinuxSystems = nixpkgs.lib.genAttrs linuxSystems;
      user = "delafthi";
    in
    {
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixpkgs-fmt);
      packages = forDarwinSystems
        (system: {
          darwinConfigurations = {
            "Thierrys-MacBook-Air" = darwin.lib.darwinSystem {
              inherit system;
              specialArgs = { inherit inputs; };
              modules = [
                ./modules/darwin/configuration.nix
                home-manager.darwinModules.home-manager
                {
                  home-manager = {
                    extraSpecialArgs =  { inherit tokyonight; };
                    useUserPackages = true;
                    users.${user} = import ./modules/home-manager/darwin/home.nix;
                  };
                  users.users.${user}.home = "/Users/${user}";
                }
              ];
            };
          };
        }) // forLinuxSystems (system:
        {
          nixosConfigurations = {
            "thierrys-workstation" = nixpkgs.lib.nixosSystem {
              inherit system;
              specialArgs = { inherit inputs; };
              modules = [
                ./modules/nixos/configuration.nix
                home-manager.nixosModules.home-manager
                {
                  home-manager = {
                    extraSpecialArgs =  { inherit tokyonight; };
                    useUserPackages = true;
                    users.${user} = import ./modules/home-manager/linux/home.nix;
                  };
                  users.users.${user}.home = "/home/${user}";
                }
              ];
            };
          };
        });
    };
}
