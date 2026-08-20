{
  imports = [
    ./boot.nix
    ./console.nix
    ./disko.nix
    ./documentation.nix
    ./hardware-configuration.nix
    ./home-manager.nix
    ./networking.nix
    ./scripts
    ./services
    ./settings
    ./soft
    ./sops.nix
    ./ssh.nix
    ./system
    ./systemd.nix
    ./time.nix
    ./users
  ];
  environment = {
    sessionVariables = { };
  };
  environment.etc."zshenv.local".text = ''
    export ZDOTDIR="$HOME/.config/zsh"
  '';
}
