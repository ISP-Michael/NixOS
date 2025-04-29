{
  programs = {
    git = {
      enable = true;
      userName = "Michael";
      userEmail = "mtr.mikhail090905@gmail.com";

      aliases = {
        ci = "commit";
        co = "checkout";
        s = "status";
        b = "branch";
      };

      extraConfig = {
        init.defaultBranch = "main";
        credential.helper = "store";
        core.editor = "nvim";
        safe.directory = "/etc/nixos";
        log.date = "format:%d-%m-%Y_%H:%M:%S";
        format.pretty = "%h⊖%ad⊖%an⊖%s";
      };
    };
  };
}
