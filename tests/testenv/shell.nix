{ pkgs ? import (builtins.getFlake (toString ./.)).inputs.nixpkgs { }
, someArg ? null
, shellHook ? ''
  echo "Executing shellHook."
''
}:
pkgs.mkShellNoCC {
  inherit shellHook;

  nativeBuildInputs = [ pkgs.hello ];
  SHOULD_BE_SET = someArg;
  IS_SET = "OK";

  passthru = { subshell = pkgs.mkShellNoCC { THIS_IS_A_SUBSHELL = "OK"; }; };
}
