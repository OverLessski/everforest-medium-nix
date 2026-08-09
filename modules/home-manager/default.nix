{ lib, ... }:
let
  catalog = import ./application-theme-catalog.nix { inherit lib; };
in
{
  _class = "homeManager";
  imports = [
    (lib.modules.importApply ../default.nix {
      everforestModuleDescriptors = catalog.moduleDescriptors;
    })
    (
      { pkgs, ... }:
      {
        config.everforest = lib.genAttrs (catalog.ineligibleThemeNamesFor pkgs.stdenv.hostPlatform) (_: {
          enable = lib.mkForce false;
        });
      }
    )
  ];
}
