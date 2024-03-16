# Nix Templates

Templates I use for setting up language-specific development environments, based on Nix flakes.

To use these templates, run:

## Golang

- [gomod2nix](https://github.com/nix-community/gomod2nix) for building the project
- [Treefmt](https://github.com/numtide/treefmt) for project-wide formatting

```shell
mkdir my-go-proj && cd my-go-proj

# For Golang
nix flake init -t github:chzerv/nix-flake-templates#go

go mod init github.com/<username>/my-go-proj
```

> [!Tip]
>
> ```shell
> # Build the project
> nix build
> ```

## Rust

- [Fenix](https://github.com/nix-community/fenix) for installing toolchains and rust-analyzer
- [Crane](https://github.com/ipetkov/crane) for building the project
  - Let's us build the project's dependencies in a separate step and thus, avoid rebuilding them whenever we build the project
- [Treefmt](https://github.com/numtide/treefmt) for project-wide formatting

```shell
mkdir my-crate && cd my-crate
nix flake init -t github:chzerv/nix-flake-templates#typst

cargo init
cargo generate-lockfile
```

> [!Tip]
>
> ```shell
> # Build the project (Cargo.toml and Cargo.lock must be already generated!)
> nix build
>
> # Clippy and cargo-audit
> nix flake check
>
> # Project-wide formatting
> nix fmt
> ```

## Gleam

Simple template that just installs `Gleam`, `Erlang` and `rebar3`, according to the [Gleam docs](https://gleam.run/getting-started/installing/)

```shell
mkdir my-gleam-proj && cd my-gleam-proj
nix flake init -t github:chzerv/nix-flake-templates#gleam

gleam new .
```
## Terraform

```shell
mkdir my-tf-proj && cd my-tf-proj
nix flake init -t github:chzerv/nix-flake-templates#terraform
```

## LaTeX

```shell
mkdir my-latex-proj && cd my-latex-proj
nix flake init -t github:chzerv/nix-flake-templates#latex
```

## Typst

```shell
mkdir my-typst-proj && cd my-typst-proj
nix flake init -t github:chzerv/nix-flake-templates#typst
```

## TODO

- [x] Rust
- [ ] Python
- [ ] Ansible
- [x] Terraform
