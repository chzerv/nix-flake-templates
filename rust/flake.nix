{
  description = "Rust DevShell with Fenix for installing toolchains, Crane for building and treefmt for formatting";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    # For installing toolchains
    # Supports all the profiles rustup supports and provides nightly builds both for
    # toolchains and rust-analyzer
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Used for building Rust projects
    crane = {
      url = "github:ipetkov/crane";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Security advisories filed again Rust crates.
    # Used via `cargo audit` to audit `Cargo.lock` for crates with security vulnerabilities
    advisory-db = {
      url = "github:rustsec/advisory-db";
      flake = false;
    };

    # Project-wide formatter
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    fenix,
    crane,
    advisory-db,
    flake-parts,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux"];

      imports = [
        inputs.treefmt-nix.flakeModule
      ];

      perSystem = {
        system,
        lib,
        config,
        ...
      }: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [fenix.overlays.default];
        };

        # Install components from the stable toolchains
        toolchainComponents = fenix.packages.${system}.stable.withComponents [
          "rustc"
          "rust-src"
          "cargo"
          "clippy"
          "rustfmt"
        ];

        # Use the toolchain provided via Fenix for Crane
        craneLib =
          crane.lib.${system}.overrideToolchain
          fenix.packages.${system}.default.toolchain;

        # Only include cargo and Rust files as part of the source.
        # This ensure that rebuilds are avoided when irrelevant files, e.g, flake.nix, are changed
        src = craneLib.cleanCargoSource (craneLib.path ./.);

        # Declare build args here so we don't need to repeat them for `cargoArtifacts` and the crate itself
        commonArgs = {
          inherit src;
          strictDeps = true;

          pname = "foo";
          version = "v0.1.0";

          # Use the "mold" linker in Linux
          # https://github.com/rui314/mold
          nativeBuildInputs = [] ++ lib.optionals (pkgs.stdenv.isLinux) [pkgs.clang pkgs.mold];

          RUSTFLAGS = "" + lib.optionals (pkgs.stdenv.isLinux) "-C linker=clang -C link-arg=-fuse-ld=${pkgs.mold}/bin/mold";
        };

        # Build the dependencies separately so we don't have to always build them when rebuilding the crate
        cargoArtifacts = craneLib.buildDepsOnly commonArgs;

        # Build the actual crate itself, reusing the dependency artifacts
        my-crate = craneLib.buildPackage (commonArgs
          // {
            inherit cargoArtifacts;
          });
      in {
        checks = {
          # Build the crate before running any checks
          inherit my-crate;

          # Run a clippy check
          clippy = craneLib.cargoClippy (commonArgs
            // {
              inherit cargoArtifacts;
              cargoClippyExtraArgs = "--all-targets -- --deny warnings";
            });

          # cargo-audit
          audit = craneLib.cargoAudit {
            inherit src advisory-db;
          };
        };

        # Build the crate
        packages.default = my-crate;

        # Development shell containing needed tools
        devShells.default = pkgs.mkShell {
          inputsFrom = [
            config.treefmt.build.devShell
          ];

          buildInputs = [
            toolchainComponents
            pkgs.rust-analyzer-nightly
            pkgs.git
          ];
        };

        # Formatting
        treefmt.config = {
          projectRootFile = "Cargo.toml";
          programs = {
            alejandra.enable = true;
            rustfmt.enable = true;
          };
        };
      };
    };
}
