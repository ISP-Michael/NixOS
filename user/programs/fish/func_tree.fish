# function tree -w tree
    if test "$argv[-1]" = '--without-pf'
        command tree -L 1 $argv[..-2] -I '.venv|.git|.gitignore|pyproject.toml|pyrightconfig.json|.python-version|README.md|uv.lock|.sass-cache|output|biome.json' -C
    else
        command tree -L 1 $argv -C
    end
# end
