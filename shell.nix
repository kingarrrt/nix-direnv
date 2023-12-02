{ pkgs ? import <nixpkgs> { }, pkg ? pkgs.callPackage ./default.nix { }, packages ? [ ] }:

with pkgs;
mkShell {
  inputsFrom = [ pkg ];
  packages = packages ++ [
    (pkgs.buildRubyGem {
      gemName = "bashcov";
      version = "3.1.1";
      source.sha256 = "sha256-MbwKjH3B5PdzxxVwICuQjCA+sxeBoMeZ3Do9nClb6nE=";
      propagatedBuildInputs = [
        pkgs.rubyPackages.docile
        pkgs.rubyPackages.simplecov-html
        pkgs.rubyPackages.simplecov_json_formatter
        (pkgs.buildRubyGem {
          gemName = "simplecov";
          version = "0.21.2";
          source.sha256 = "sha256-mQ22rttVCG1r+IdJk/8feW5IMKv6EZN0aMpQKg0BO8M=";
        })
      ];
    })
  ];
}
