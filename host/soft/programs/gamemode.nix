{
  lib,
  ...
}:
{
  programs = {
    gamemode = {
      enable = true;
      settings.general.renice = 10;
    };
  };

  # GameMode's polkit actions (cpugovctl, procsysctl, ...) are
  # allow_any=no / allow_active=no by default, so pkexec refuses them.
  # Allow only the GameMode helper actions for this user.
  security.polkit.extraConfig = lib.mkAfter ''
    polkit.addRule(function(action, subject) {
      if (subject.user == "Michael" &&
          action.id.indexOf("com.feralinteractive.GameMode.") === 0) {
        return polkit.Result.YES;
      }
    });
  '';
}
