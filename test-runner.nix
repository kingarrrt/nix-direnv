{ writeShellScriptBin
, lib
, pkg
, gnumake
, bash
, nix
, jq
}:
writeShellScriptBin "test-runner-${nix.version}" ''
  export PATH=${lib.makeBinPath (pkg.nativeBuildInputs ++ [
    gnumake
    # XXX: these should come from pkg.nativeBuildInputs, but don't... IDK why.
    bash
    nix
    jq
  ]) }
  make test ARGV="$*"
''
