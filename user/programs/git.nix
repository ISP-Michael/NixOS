{
  programs = {
    git = {
      enable = true;
      userName = "Michael";
      userEmail = "mtr.mikhail090905@gmail.com";
      aliases = {
        s = "status";
        b = "branch";
        ci = "commit";
        co = "checkout";
      };
      extraConfig = {
        core.editor = "nvim";
        init.defaultBranch = "main";
        credential.helper = "store";
        safe.directory = "/etc/nixos";
        format.pretty = "%h⊖%ad⊖%an⊖%s";
        log.date = "format:%d-%m-%Y_%H:%M:%S";
      };
    };
  };
}
