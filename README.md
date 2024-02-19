# Nix Templates

Templates for setting up language-specific development environments, using Nix flakes.

To use these templates, run:

```shell
mkdir template-demo && cd template-demo

# For Golang
nix flake init -t github:chzerv/nix-flake-templates#go

# For LaTeX
nix flake init -t github:chzerv/nix-flake-templates#latex
```

## Supported languages

So far, there are templates for the following languages:

+ Golang, with `gomod2nix` for builds
+ LaTeX
+ Typst


## TODO

+ [ ] Rust
+ [ ] Python
+ [ ] Ansible
+ [ ] Terraform
