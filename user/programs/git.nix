{
  programs = {
    git = {
      enable = true;
      settings = {
        user = {
          name = "Michael";
          email = "mtr.mikhail090905@gmail.com";
        };
        core.editor = "nvim";
        init.defaultBranch = "main";
        credential.helper = "store";
        safe.directory = "/etc/nixos";
      };
    };
  };
}
