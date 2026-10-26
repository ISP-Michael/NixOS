{
  lib,
  ...
}:
{
  nixpkgs.overlays = [
    (final: prev:
      let
        # sphinx-hook читает список сборщиков как строку:
        #   eval "__sphinxBuilders=($sphinxBuilders)"
        # При structured attrs список из nixpkgs превращается в bash-массив, и
        # `$sphinxBuilders` раскрывается только в первый элемент ("html"). Выход
        # man не создаётся, и пакеты с outputs = [ "out" "doc" "man" ] (khal,
        # python3.14-reuse) падают: "failed to produce output path for output 'man'".
        # [*] склеивает массив в строку, так что и строка, и массив работают.
        # Апстрим: NixOS/nixpkgs#573479 — когда починят, оверлей можно убрать.
        #
        # Патчим и топ-level sphinxHook (им пользуются пакеты из pkgs/by-name),
        # и sphinxHook внутри python3Packages (им пользуются python-модули вроде
        # reuse): это разные экземпляры одного и того же хука.
        fixSphinxHook =
          hook:
          prev.makeSetupHook {
            name = "python3.14-sphinx-hook-array-fix";
            propagatedBuildInputs = [
              prev.python3Packages.sphinx
              prev.installShellFiles
            ];
            passthru.provides.setupHook = true;
          } (prev.writeText "sphinx-hook.sh" (lib.replaceStrings
            [ "eval \"__sphinxBuilders=($sphinxBuilders)\"" ]
            [ "eval \"__sphinxBuilders=(\${sphinxBuilders[*]})\"" ]
            (builtins.readFile "${hook}/nix-support/setup-hook")));
      in
      {
        python3Packages = prev.python3Packages.overrideScope (self: super: {
          sphinxHook = fixSphinxHook super.sphinxHook;
          # reuse получает sphinxHook не из self, а из spliced0 (топ-level prev),
          # поэтому overrideScope до него не доходит. Задаём обходной путь явно.
          reuse = super.reuse.overrideAttrs (_: {
            sphinxBuilders = [ "html man" ];
          });
        });
        sphinxHook = fixSphinxHook prev.python3Packages.sphinxHook;
        reuse = prev.reuse.overrideAttrs (_: {
          sphinxBuilders = [ "html man" ];
        });
      })
  ];
}
