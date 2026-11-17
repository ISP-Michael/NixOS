{
  programs = {
    ssh.startAgent = true;
    fuse.userAllowOther = true;
  };

  # ssh-keygen может создать host-ключи с umask 0022 (0644). Приватные
  # ключи не должны быть читаемы другим пользователям; публичные .pub
  # не трогаем.
  system.activationScripts.sshHostKeyPerms = ''
    for key in /etc/ssh/ssh_host_*_key; do
      [ -f "$key" ] && chmod 600 "$key"
    done
  '';
}
