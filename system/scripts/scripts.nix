{
  environment.etc."chmod.sh" = {
    text = ''
      #!/bin/sh
      chmod 777 /etc/nixos
    '';
    mode = "0755";
  };
}
