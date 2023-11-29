load lib

eval "$(direnv stdlib)"
# shellcheck disable=1090
source "$DIRENVRC"

# override _nix_direnv_fatal because it calls "exit"
_nix_direnv_fatal() {
  echo >&2 "$@"
  return 1
}

@test nix_direnv_version {
  assert nix_direnv_version 2
}

@test "nix_direnv_version: too old" {
  refute nix_direnv_version 99
  assert_error --partial "older than the desired"
}
