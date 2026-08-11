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
in
{
  options.everforest.${applicationThemeName} = everforestLib.mkEverforestOption {
    name = applicationThemeName;
  };

  config = lib.mkIf (cfg.enable && config.qt.enable) {
    assertions = [
      {
        assertion = config.qt.platformTheme.name == "qt6ct";
        message = "qt.platformTheme.name must be 'qt6ct' to use everforest.qt6ct";
      }
    ];

    xdg.configFile."qt6ct/colors/Everforest-Medium.conf".text =
      lib.readFile ../../pkgs/qt6ct/Everforest-Medium.conf;

    qt.qt6ctSettings = {
      Appearance = {
        custom_palette = true;
        color_scheme_path = "${config.xdg.configHome}/qt6ct/colors/Everforest-Medium.conf";
      };
    };
  };
}
