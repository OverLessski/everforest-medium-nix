{ applicationThemeNames, everforestLib, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  applicationThemeName =
    if builtins.length applicationThemeNames == 1 then
      builtins.head applicationThemeNames
    else
      throw "Home Manager single-theme module expected exactly one Application Theme name";
  cfg = config.everforest.${applicationThemeName};
  everforest-medium-yazi = pkgs.fetchFromGitHub {
    owner = "Chromium-3-Oxide";
    repo = "everforest-medium.yazi";
    rev = "e1ead7b5a3bfc8eb572fd269a369775842752705";
    hash = "sha256-2Fx7+xnSsc+aVHBZUtLtVUDEzb1y8BcPBASciKk8x7o=";
  };
in
{
  options.everforest.${applicationThemeName} = everforestLib.mkEverforestOption {
    name = applicationThemeName;
  };
  config = lib.mkIf (cfg.enable && config.programs.yazi.enable) {
    programs.yazi = {
      flavors = {
        everforest-medium = "${everforest-medium-yazi}";
      };
      theme.flavor = {
        dark = "everforest-medium";
        light = "everforest-medium";
        use = "everforest-medium";
      };
    };
  };
}
