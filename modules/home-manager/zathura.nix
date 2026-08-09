{
  applicationThemeNames,
  everforestLib,
  everforestPalette,
}:
{ config, lib, ... }:
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
  config = {
    programs.zathura.options = lib.mkIf (cfg.enable && config.programs.zathura.enable) {
      default-bg = lib.mkDefault everforestPalette.bg0;
      default-fg = lib.mkDefault everforestPalette.fg;
      statusbar-bg = lib.mkDefault everforestPalette.bg1;
      statusbar-fg = lib.mkDefault everforestPalette.fg;
      inputbar-bg = lib.mkDefault everforestPalette.statusline1;
      inputbar-fg = lib.mkDefault everforestPalette.bg0;
      notification-bg = lib.mkDefault everforestPalette.bg_blue;
      notification-fg = lib.mkDefault everforestPalette.blue;
      notification-error-bg = lib.mkDefault everforestPalette.bg_red;
      notification-error-fg = lib.mkDefault everforestPalette.red;
      notification-warning-bg = lib.mkDefault everforestPalette.bg_yellow;
      notification-warning-fg = lib.mkDefault everforestPalette.yellow;
      highlight-color = lib.mkDefault everforestPalette.yellow;
      highlight-active-color = lib.mkDefault everforestPalette.red;
      completion-bg = lib.mkDefault everforestPalette.bg2;
      completion-fg = lib.mkDefault everforestPalette.fg;
      completion-highlight-bg = lib.mkDefault everforestPalette.statusline1;
      completion-highlight-fg = lib.mkDefault everforestPalette.bg0;
      recolor-darkcolor = lib.mkDefault everforestPalette.bg0;
      recolor-lightcolor = lib.mkDefault everforestPalette.fg;
      recolor = lib.mkDefault true;
      recolor-keephue = lib.mkDefault false;
    };
  };
}
