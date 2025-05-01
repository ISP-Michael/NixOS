# function git -w git
    if test "$argv[1]" = 'log'
        if contains -- '--graph' $argv
            command git $argv
        else
            command git log $argv[2..-1] | ~/Projects/Python/.venv/bin/python3.13 ~/Projects/Python/git-log-short.py | column -ts '⊖' | bat # --highlight-line 0:
        end
    else if test "$argv[1]" = 'reflog'
        command git reflog $argv[2..-1] | ~/Projects/Python/.venv/bin/python3.13 ~/Projects/Python/git-reflog.py | bat # --highlight-line 0:
    else
        command git $argv
    end
# end
