{ stdenv
, nix
, lib
, bash
, coreutils
, bats
, parallel
, jq
, gitMinimal
, rsync
, findutils
, direnv
}:

stdenv.mkDerivation {
  name = "nix-direnv";

  src = ./.;

  postPatch = ''
    sed -i "2iNIX_BIN_PREFIX=${nix}/bin" direnvrc
  '';

  # Makefile is used for test only
  buildPhase = "true";

  installPhase = ''
    install -m400 -D direnvrc $out/share/nix-direnv/direnvrc
  '';

  nativeCheckInputs = [
    nix
    bash
    coreutils
    (bats.withLibraries (p: [ p.bats-support p.bats-assert ]))
    parallel
    jq
    gitMinimal
    rsync
    findutils
    direnv
  ];

  # XXX: these are the only pure tests :-(
  checkPhase = "make test TEST_PATH=tests/test_api.bash";

  doCheck = true;

  meta = with lib; {
    description = "A fast, persistent use_nix implementation for direnv";
    homepage = "https://github.com/nix-community/nix-direnv";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
