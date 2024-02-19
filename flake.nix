{
  description = "Development Environments via Nix Flake Templates";

  outputs = {self, ...}: {
    templates = {
      go = {
        path = ./go;
        description = "Start a Go project";
      };
      latex = {
        path = ./latex;
        description = "Start a LaTeX project";
      };
      typst = {
        path = ./typst;
        description = "Start a Typst project";
      };
    };
  };
}
