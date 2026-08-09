{ everforestModuleDescriptors }:
{
  pkgs,
  config,
  lib,
  ...
}:
let
  everforestLib = import ./lib { inherit pkgs config lib; };
  everforestPalette = import ../palette;
in
{
  options.everforest = {
    enable = lib.mkEnableOption "everforest globally";
    palette = lib.mkOption {
      default = everforestPalette;
      readOnly = true;
      type = lib.types.attrsOf lib.types.str;
      description = "The Everforest theme's palette.";
    };
  };
  imports = map (
    descriptor:
    lib.modules.importApply descriptor.file {
      inherit everforestLib everforestPalette;
      inherit (descriptor) applicationThemeNames;
    }
  ) everforestModuleDescriptors;
}
