{ pkgs ? import <nixpkgs> { }, pkg ? pkgs.callPackage ./default.nix { }, packages ? [ ] }:

with pkgs;
mkShell {
  inputsFrom = [ pkg ];
  inherit packages;
}
