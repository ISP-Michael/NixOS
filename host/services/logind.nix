{
  services = {
    logind = {
      enable = true;
      settings = {
        Login = {
          HandleLidSwitch = "suspend-then-hibernate";
          HibernateDelaySec = "2h";
        };
      };
    };
  };
}
