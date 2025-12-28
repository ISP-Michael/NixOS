{
  config,
  ...
}:
{
  programs = {
    git = {
      enable = true;
      settings = {
        alias = {
          s = "status";
          b = "branch";
          ci = "commit";
          co = "checkout";
        };
        user = {
          name = "Michael";
          email = "mtr.mikhail090905@gmail.com";
        };
        core = {
          editor = "nvim";
        };
        init = {
          defaultBranch = "main";
        };
        credential = {
          helper = "store";
        };
        safe = {
          directory = "/etc/nixos";
        };
        format = {
          pretty = "[33m%h[0m × [34m%ad[0m × [31m%an[0m × %s";
        };
        log = {
          date = "format:%d-%m-%Y_%H:%M:%S";
        };
      };
    };
  };
}
