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
          name = "fzf";
          src = fzf-fish;
        }
        {
          name = "async-prompt";
          src = async-prompt;
        }
        {
          name = "fifc";
          src = fifc;
        }
      ];
    };
  };
}
