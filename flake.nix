{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/23.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        r-packages = with pkgs.rPackages; [ tidyverse geomtextpath kableExtra ];
      in {
        devShells = {
          default = pkgs.mkShell {
            packages = with pkgs; [
              # Workflow related
              snakemake

              # Analysis related
              (rWrapper.override { packages = r-packages; })

              # Paper related
              texlive.combined.scheme-full
              rubber
            ];
          };
        };
      });
}
