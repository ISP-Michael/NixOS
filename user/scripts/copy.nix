{
  lib,
  ...
}:
{
  home = {
    activation = {
      copyConfigs = lib.hm.dag.entryAfter ["writeBoundary"] ''
        SRC_DIR="${./.config}"
        DEST_DIR="$HOME/.config"
        mkdir -p "$DEST_DIR"
        for item in "$SRC_DIR"/*; do
          name=$(basename "$item")
          TARGET="$DEST_DIR/$name"
          if [ ! -e "$TARGET" ]; then
            cp -rp "$item" "$TARGET"
            chmod -R u+w "$TARGET"
          fi
        done
      '' ;
    };
  };
}

