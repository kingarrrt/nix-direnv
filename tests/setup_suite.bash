setup_suite() {

  PROJECT_ROOT="$(dirname "$BATS_TEST_DIRNAME")"

  TEST_ENV="$BATS_TEST_DIRNAME/testenv"

  DIRENVRC="$PROJECT_ROOT/direnvrc"

  export PROJECT_ROOT TEST_ENV DIRENVRC

  # on Linux we can use a chroot for /nix
  if [ "$(uname)" = "Linux" ]; then

    CHROOT="$BATS_TEST_DIRNAME/.chroot"

    # seed chroot /nix/store with ./tests/testenv/flake.nix inputs
    # TODO: the rest
    TEST_STORE="$CHROOT/nix/store"
    mkdir -p "$TEST_STORE"
    for source in $(nix flake archive --json "$TEST_ENV" |
      jq --raw-output '.inputs | [.. | .path? | select(.)]| sort | unique | .[]'); do
      rsync -a "$source" "$TEST_STORE/"
    done

    # write a wrapper for nix to make it use the chroot store, write this every time as
    # this script may be run with multiple nix versions
    CHROOT_BIN="$CHROOT/bin"
    [ -d "$CHROOT_BIN" ] || mkdir "$CHROOT_BIN"
    nix=$(command -v nix)
    NIX_WRAPPER="$CHROOT_BIN/nix"
    cat <<EOF > "$NIX_WRAPPER"
  #!/usr/bin/env bash
exec $nix --store $CHROOT "\$@"
EOF
    chmod +x "$NIX_WRAPPER"
    PATH=$CHROOT_BIN:$PATH

    # https://bford.info/cachedir/
    echo "Signature: 8a477f597d28d172789f06886806bc55" > "$CHROOT/CACHEDIR.TAG"

  fi

  # unset XDG_CONFIG_HOME so direnv picks does not pick up user customization
  # unset XDG_DATA_HOME so direnv allow state writes under tmp HOME
  unset XDG_CONFIG_HOME XDG_DATA_HOME

}
