RENEWED_CACHE="renewed cache"

USING_CACHED="using cached dev shell"

_test_use_common() {
  assert_setup_envrc "$USE"
  assert_find_count ".direnv -maxdepth 1 -type f" 1
  assert_find_count ".direnv -maxdepth 1 -type l" 1
  assert_direnv_exec "$USING_CACHED"
  touch .envrc
  assert_direnv_exec "$RENEWED_CACHE"
  [ "$(uname)" == "Linux" ] || skip "GC test only on Linux"
  assert nix store gc -v
  assert_output --partial "store paths deleted"
  assert_direnv_exec "$USING_CACHED"
}
