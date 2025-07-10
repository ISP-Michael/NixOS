{ inputs, ... }:
{
  programs = {
    fish = {
      plugins = [
        { name = "autopair"; src  = inputs.autopair; }
        { name =     "done"; src  =     inputs.done; }
        { name =      "fzf"; src  =      inputs.fzf; }
      ];
    };
  };
}
