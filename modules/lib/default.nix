{ config, lib, ... }:
let
  renderHyprColor = color: lib.substring 1 6 color;
in
{
  mkEverforestOption = { name }: {
    enable = lib.mkEnableOption "Whether to enable Everforest theme for ${name}" // {
      default = config.everforest.enable;
    };
  };

  renderHyprPalette =
    palette:
    lib.concatStringsSep "\n" (
      lib.attrValues (lib.mapAttrs (name: color: "\$${name} = rgb(${renderHyprColor color})") palette)
    );
}
