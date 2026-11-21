{ pkgs }:
# Noctalia 5.5.0 (upstream latest) + локальный фикс fingerprint release.
# В 5.5.0 upstream всё ещё не отпускает device, если Claim завершился после
# разблокировки; патч нужен, иначе sudo/локскрин могут получить "already claimed".
#
# Кэша для такого derivation нет: локальный патч меняет hash. Тесты отключены,
# чтобы не компилировать 164 тестовых бинаря; сборка идёт медленно через
# scripts/build-slow.sh (один core, idle I/O, лимит памяти).
pkgs.noctalia.overrideAttrs (old: {
  version = "5.5.0";

  src = pkgs.fetchFromGitHub {
    owner = "noctalia-dev";
    repo = "noctalia";
    tag = "v5.5.0";
    hash = "sha256-JFT5v+NFN6j/5nDZ5oKizflUsGJNMvwCOdt+4zZ0IX8=";
  };

  patches =
    (old.patches or [ ])
    ++ [
      ./claim-release.patch
    ];

  doCheck = false;

  mesonFlags =
    pkgs.lib.filter (
      flag:
      !(pkgs.lib.hasPrefix "-Dtests=" flag)
    )
    old.mesonFlags
    ++ [
      "-Dtests=disabled"
    ];
})
