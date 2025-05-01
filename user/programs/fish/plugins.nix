{ pkgs, ... }:
{
  programs.fish.plugins = with pkgs; [
    {
      name = "fihser";
      src = fetchFromGitHub {
        owner = "jorgebucaran";
        repo = "fisher";
        rev = "1f0dc2b4970da160605638cb0f157079660d6e04";
        sha256 = "pR5RKU+zIb7CS0Y6vjx2QIZ8Iu/3ojRfAcAdjCOxl1U=";
      };
    }
    {
      name = "autopair";
      src = fetchFromGitHub {
        owner = "jorgebucaran";
        repo = "autopair.fish";
        rev = "4d1752ff5b39819ab58d7337c69220342e9de0e2";
        sha256 = "qt3t1iKRRNuiLWiVoiAYOu+9E7jsyECyIqZJ/oRIT1A=";
      };
    }
    {
      name = "done";
      src = fetchFromGitHub {
        owner = "franciscolourenco";
        repo = "done";
        rev = "eb32ade85c0f2c68cbfcff3036756bbf27a4f366";
        sha256 = "DMIRKRAVOn7YEnuAtz4hIxrU93ULxNoQhW6juxCoh4o=";
      };
    }
    {
      name = "fzf";
      src = fetchFromGitHub {
        owner = "patrickf1";
        repo = "fzf.fish";
        rev = "8920367cf85eee5218cc25a11e209d46e2591e7a";
        sha256 = "T8KYLA/r/gOKvAivKRoeqIwE2pINlxFQtZJHpOy9GMM=";
      };
    }
  ];
}
