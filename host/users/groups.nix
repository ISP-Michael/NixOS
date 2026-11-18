{
  config,
  ...
}:
{
  users = {
    groups = {
      libvirtd = {
        members = [
          config.host.user
        ];
      };
      media = {

      };
    };
  };
}
