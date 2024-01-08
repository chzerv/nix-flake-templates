{
  description = "Development Environments via Nix Flake Templates";

  outputs = {self, ...}: {
    templates = {
      go = {
        path = ./go;
        description = "Start a Go project";
      };
    };
  };
}
