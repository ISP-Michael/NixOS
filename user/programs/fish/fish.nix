{
  programs = {
    fish = {
      enable = true;
      generateCompletions = false;
      interactiveShellInit = ''
        fish_vi_key_bindings
      '';
    };
  };
}
