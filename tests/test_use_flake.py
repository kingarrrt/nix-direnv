from __future__ import annotations

import os
import subprocess

import pytest

from .case import TestCase


class TestUseFlake(TestCase):
    @pytest.mark.parametrize("strict_env", [False, True])
    def test_usage(self, strict_env: bool) -> None:
        self.setup_envrc("use flake", strict_env=strict_env)
        self.assert_usage("flake.nix")

    @pytest.mark.parametrize("strict_env", [False, True])
    def test_bad_usage(self, strict_env: bool) -> None:
        self.setup_envrc("use flake --impure", strict_env=strict_env)
        with pytest.raises(subprocess.CalledProcessError) as exc:
            self.direnv_exec("true")
        must_be_flake = "the first argument must be a flake expression"
        did_you_mean = "did you mean 'use flake . --impure'?"
        assert must_be_flake in exc.value.stderr
        assert did_you_mean in exc.value.stderr
        self.setup_envrc("use flake --impure .", strict_env=strict_env)
        with pytest.raises(subprocess.CalledProcessError) as exc:
            self.direnv_exec("true")
        assert must_be_flake in exc.value.stderr
        assert did_you_mean not in exc.value.stderr
        self.setup_envrc("use flake /no/such", strict_env=strict_env)
        with pytest.raises(subprocess.CalledProcessError) as exc:
            self.direnv_exec("true")
        assert 'flake directory "/no/such" not found' in exc.value.stderr

    @pytest.mark.parametrize("strict_env", [False, True])
    def test_env_set(self, strict_env: bool) -> None:
        self.setup_envrc("use flake", strict_env=strict_env)
        result = self.assert_direnv_var("IS_SET")
        assert "renewed cache" in result.stderr

    def _force_refresh(self) -> None:
        self.run("sed", "-i", "1i#", "flake.nix")
        result = self.direnv_exec("true")
        assert "renewed cache" in result.stderr

    @pytest.mark.parametrize("strict_env", [False, True])
    def test_cache_cleanup(self, strict_env: bool) -> None:
        self.setup_envrc("use flake", strict_env=strict_env)
        result = self.direnv_exec("true")
        assert "renewed cache" in result.stderr
        self._force_refresh()
        caches = self.cache_dirs
        assert len(caches) == 2
        for cache in caches:
            os.utime(cache, (0, 0))
        self._force_refresh()
        assert len(self.cache_dirs) == 1

    @pytest.mark.parametrize("strict_env", [False, True])
    def test_cache_cleanup_no_retention(self, strict_env: bool) -> None:
        self.setup_envrc("nix_direnv_keep_days 0\nuse flake", strict_env=strict_env)
        result = self.direnv_exec("true")
        assert "renewed cache" in result.stderr
        assert len(self.cache_dirs) == 1
        self._force_refresh()
        assert len(self.cache_dirs) == 1
