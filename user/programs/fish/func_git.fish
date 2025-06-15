# function git -w git
    if test "$argv[1]" = 'log'
        if contains -- '--graph' $argv
            command git $argv
        else
            command git log $argv[2..-1] | /etc/nixos/dependencies/git/git-log-short.bin | column -ts '⊖' | bat
        end
    else if test "$argv[1]" = 'reflog'
        command git reflog $argv[2..-1] | /etc/nixos/dependencies/git/git-reflog.bin | bat
    else
        command git $argv
    end
# end
