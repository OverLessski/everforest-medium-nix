{
  applicationThemeNames,
  everforestLib,
  everforestPalette,
}:
{
  pkgs,
  config,
  lib,
  ...
}:
let
  applicationThemeName =
    if builtins.length applicationThemeNames == 1 then
      builtins.head applicationThemeNames
    else
      throw "Home Manager single-theme module expected exactly one Application Theme name";
  cfg = config.everforest.${applicationThemeName};
  fileName = "everforest.tmTheme";
in
{
  options.everforest.${applicationThemeName} = everforestLib.mkEverforestOption {
    name = applicationThemeName;
  };
  config = lib.mkIf (cfg.enable && config.programs.bat.enable) {
    xdg.configFile."bat/themes/${fileName}".text = lib.readFile ../../pkgs/bat/everforest.tmTheme;
    programs.bat = {
      config.theme = lib.mkDefault "everforest";
    };
  };
}
