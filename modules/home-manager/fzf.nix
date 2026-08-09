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
  config = lib.mkIf (cfg.enable && config.programs.fzf.enable) {
    programs.fzf.colors = lib.mkDefault {
      bg = everforestPalette.bg0;
      "bg+" = everforestPalette.bg4;
      fg = everforestPalette.fg;
      "fg+" = everforestPalette.green;
      hl = everforestPalette.red;
      "hl+" = everforestPalette.red;
      gutter = everforestPalette.bg4;
      separator = everforestPalette.bg4;
      border = everforestPalette.bg4;
      spinner = everforestPalette.yellow;
      disabled = everforestPalette.grey1;
      info = everforestPalette.blue;
      header = everforestPalette.grey1;
      marker = everforestPalette.green;
      prompt = everforestPalette.green;
      pointer = everforestPalette.green;
    };
  };
}
