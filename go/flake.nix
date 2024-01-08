{
  description = "Golang Development Environment";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    gomod2nix = {
      url = "github:tweag/gomod2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-parts,
    gomod2nix,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux"];

      perSystem = {
        system,
        pkgs,
        ...
      }: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [gomod2nix.overlays.default];
        };
      in {
        formatter = pkgs.treefmt;

        packages = {
          default = pkgs.buildGoApplication {
            pname = "my-app";
            version = "0.1.0";
            src = ./.;
            pwd = ./.;
            modules = ./gomod2nix.toml;

            # buildInputs = with pkgs; [pkg-config libaom libavif];
          };
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            go
            go-tools
            golangci-lint
            gopls
            gofumpt
            gomod2nix.packages.${system}.default
          ];

          shellHook = ''
            echo -e "#####################################################################"
            echo -e "Don't forget to run 'gomod2nix generate' to generate 'gomod2nix.toml'"
            echo -e "or 'gomod2nix import' to import dependencies!"
            echo -e "#####################################################################"
          '';
        };
      };
    };
}
