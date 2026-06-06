{
  inputs,
  unstable-pkgs,
  ...
}:
{
  imports = [
    "${inputs.nixos-unstable}/nixos/modules/programs/clash-verge.nix"
  ];
  disabledModules = [
    "programs/clash-verge.nix"
  ];
  programs = {
    clash-verge = {
      enable = true;
      package = unstable-pkgs.clash-verge-rev;
      tunMode = true;
      serviceMode = true;
    };
  };
}
