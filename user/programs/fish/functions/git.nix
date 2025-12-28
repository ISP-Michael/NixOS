{ self, ... }:
{
  programs = {
    fish = {
      functions = {
        git = ''
          if test "$argv[1]" = 'log'
              if contains -- '--graph' $argv
                  command git $argv
              else
                  command git log $argv[2..-1] | py ${self}/dependencies/git/git-log-short.py | column -ts '×' | bat
              end
          else if test "$argv[1]" = 'reflog'
              command git reflog $argv[2..-1] | py ${self}/dependencies/git/git-reflog.py | bat
          else
              command git $argv
          end
        '';
      };
    };
  };
}
