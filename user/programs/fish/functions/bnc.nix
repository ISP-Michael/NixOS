{
  self,
  ...
}:
{
  programs = {
    fish = {
      functions = {
        bncs = ''
          command echo $argv | python ${self}/dependencies/scripts/change_brightness.py > /dev/null 2>&1
        '';
      };
    };
  };
}

