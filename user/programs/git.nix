{
  identity,
  ...
}:
{
  programs = {
    git = {
      enable = true;
      settings = {
        user = {
          name = identity.gitName;
          email = identity.gitEmail;
        };
        core.editor = "nvim";
        init.defaultBranch = "main";
        credential.helper = "store";
        safe.directory = identity.repoPath;
      };
    };
  };
}
