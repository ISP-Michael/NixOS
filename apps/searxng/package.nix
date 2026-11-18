{ pkgs }:
# SearXNG из upstream master, а не из nixpkgs-снапшота.
# Версия/rev обновляются вручную: bump rev + hash, затем собрать ISO.
pkgs.searxng.overrideAttrs (old: {
  version = "0-unstable-2026-11-17";
  src = pkgs.fetchFromGitHub {
    owner = "searxng";
    repo = "searxng";
    rev = "b99cf7496eeb837e4c60a17eacaa60fe946fc4e4";
    hash = "sha256-BFmDpT8UM9YzU8zKmfWDMWnmWEeBEptCVF3C9kUIt84=";
  };

  # Upstream master (2026-11-17) требует python-dateutil>=3, которого
  # ещё нет в nixpkgs; API совместим с 2.x, поэтому расслабляем.
  postPatch = (old.postPatch or "") + ''
    sed -i 's/python-dateutil>=.*/python-dateutil/' requirements.txt
  '';
})
