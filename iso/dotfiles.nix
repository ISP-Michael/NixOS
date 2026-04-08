{
  system = {
    activationScripts = {
      copyConfigs = ''
        mkdir -p /home/nixos/.config/{hypr,nvim}
        cp -rf ./hypr/* /home/nixos/.config/hypr
        cp -rf ./nvim/* /home/nixos/.config/nvim
        chown -R nixos:users /home/nixos/.config
      '';
    };
  };
}
