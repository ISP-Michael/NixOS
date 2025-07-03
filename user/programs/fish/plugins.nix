{ inputs, ... }:
{
  programs = {
    fish = {
      plugins = [
        {
          name = "fihser";
          src  = inputs.fisher ;
        }
        {
          name = "autopair";
          src  = inputs.autopair;
        }
        {
          name = "done";
          src  = inputs.done;
        }
        {
          name = "fzf";
          src  = inputs.fzf;
        }
      ];
    };
  };
}
