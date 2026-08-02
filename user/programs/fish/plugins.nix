{
  pkgs,
  ...
}:
{
  programs = {
    fish = {
      plugins = with pkgs.fishPlugins; [
        {
          name = "autopair";
          src = autopair;
        }
        {
          name = "done";
          src = done;
        }
        {
          name = "fifc";
          src = fifc;
        }
        {
          name = "fzf";
          src = fzf-fish;
        }
      ];
    };
  };
}
