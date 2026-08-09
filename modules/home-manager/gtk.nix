{ applicationThemeNames, everforestLib, ... }:
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
  everforest-gtk-theme-medium = pkgs.stdenv.mkDerivation rec {
    name = "everforest-gtk-theme-medium";
    pname = name;
    src = pkgs.fetchFromGitHub {
      owner = "Fausto-Korpsvart";
      repo = "Everforest-GTK-Theme";
      rev = "dbd1014f4f3b66d5258bf81e9135e0e75cea084d";
      hash = "sha256-QfawNkstj3cdIEN60dLrk3a1U4lNTclF7NLB++PrnHE=";
    };
    dontBuild = true;
    buildInputs = [
      pkgs.gnome-themes-extra
      pkgs.sassc
    ];
    propagatedUserEnvPkgs = [ pkgs.gtk-engine-murrine ];
    installPhase = ''
      runHook preInstall
      # Prepare folders and index.theme
      ${pkgs.coreutils-full}/bin/mkdir -p "$out/share/"{themes/everforest/{gtk-2.0,gtk-3.0,gtk-4.0},icons}
      ${pkgs.coreutils-full}/bin/cp -rf icons/Everforest-Dark "$out/share/icons"
      ${pkgs.coreutils-full}/bin/cp -rf themes/src "$out/share/src"
      ${pkgs.coreutils-full}/bin/echo "Type=X-GNOME-Metatheme" >> "$out/share/themes/everforest/index.theme"
      ${pkgs.coreutils-full}/bin/echo "[Desktop Entry]" >> "$out/share/themes/everforest/index.theme"
      ${pkgs.coreutils-full}/bin/echo "Name=Everforest-Dark-Medium" >> "$out/share/themes/everforest/index.theme"
      ${pkgs.coreutils-full}/bin/echo "Comment=An Flat Gtk+ theme based on Elegant Design" >> "$out/share/themes/everforest/index.theme"
      ${pkgs.coreutils-full}/bin/echo "Encoding=UTF-8" >> "$out/share/themes/everforest/index.theme"
      # Apply dark medium theme
      ${pkgs.coreutils-full}/bin/cp -rf "$out/share/src/sass/_tweaks.scss" "$out/share/src/sass/tweaks-temp.scss"
      ${pkgs.gnused}/bin/sed -i "/\@import/s/color-palette-default/color-palette-medium/" "$out/share/src/sass/tweaks-temp.scss"
      ${pkgs.gnused}/bin/sed -i "/\$colorscheme:/s/default/medium/" "$out/share/src/sass/tweaks-temp.scss"
      # GTK 2
      ${pkgs.coreutils-full}/bin/cp -r "$out/share/src/main/gtk-2.0/common/"*.rc "$out/share/themes/everforest/gtk-2.0"
      ${pkgs.coreutils-full}/bin/cp -r "$out/share/src/assets/gtk-2.0/assets-common-Dark" "$out/share/themes/everforest/gtk-2.0/assets"
      ${pkgs.coreutils-full}/bin/cp -r "$out/share/src/assets/gtk-2.0/assets-Green-Dark-Medium/"*png "$out/share/themes/everforest/gtk-2.0/assets"
      # GTK 3
      ${pkgs.coreutils-full}/bin/cp -r "$out/share/src/assets/gtk/assets-Green-Medium" "$out/share/themes/everforest/gtk-3.0/assets"
      ${pkgs.coreutils-full}/bin/cp -r "$out/share/src/assets/gtk/scalable" "$out/share/themes/everforest/gtk-3.0/assets"
      ${pkgs.coreutils-full}/bin/cp -r "$out/share/src/assets/gtk/thumbnails/thumbnail-Green-Medium-Dark.png" "$out/share/themes/everforest/gtk-3.0/thumbnail.png"
      ${pkgs.sassc}/bin/sassc -M -t expanded "$out/share/src/main/gtk-3.0/gtk-Dark.scss" "$out/share/themes/everforest/gtk-3.0/gtk-dark.css"
      ${pkgs.sassc}/bin/sassc -M -t expanded "$out/share/src/main/gtk-3.0/gtk-Dark.scss" "$out/share/themes/everforest/gtk-3.0/gtk.css"
      # GTK 4
      ${pkgs.coreutils-full}/bin/cp -r "$out/share/src/assets/gtk/scalable" "$out/share/themes/everforest/gtk-4.0/assets"
      ${pkgs.coreutils-full}/bin/cp -r "$out/share/src/assets/gtk/thumbnails/thumbnail-Green-Medium-Dark.png" "$out/share/themes/everforest/gtk-4.0/thumbnail.png"
      ${pkgs.sassc}/bin/sassc -M -t expanded "$out/share/src/main/gtk-4.0/gtk-Dark.scss" "$out/share/themes/everforest/gtk-4.0/gtk-dark.css"
      ${pkgs.sassc}/bin/sassc -M -t expanded "$out/share/src/main/gtk-4.0/gtk-Dark.scss" "$out/share/themes/everforest/gtk-4.0/gtk.css"
      # gtkrc
      ${pkgs.coreutils-full}/bin/cp -r "$out/share/src/main/gtk-2.0/gtkrc-Dark-Medium" "$out/share/themes/everforest/gtk-2.0/gtkrc"
      runHook postInstall
    '';
    postInstall = ''
      ${pkgs.coreutils-full}/bin/rm -rf "$out/share/src"
    '';
  };
in
{
  options.everforest.${applicationThemeName} = everforestLib.mkEverforestOption {
    name = applicationThemeName;
  };
  config = lib.mkIf (cfg.enable && config.gtk.enable) {
    gtk = {
      theme = lib.mkDefault {
        name = "Everforest-Dark-Medium";
        package = everforest-gtk-theme-medium;
      };
      iconTheme = lib.mkDefault {
        name = "Everforest-Dark";
        package = everforest-gtk-theme-medium;
      };
      gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
    };
    dconf.settings = {
      "org/gnome/shell" = {
        disable-user-extensions = false;
        enabled-extensions = [ "user-theme@gnome-shell-extensions.gcampax.github.com" ];
      };
      "org/gnome/shell/extensions/user-theme" = {
        inherit (config.gtk.theme) name;
      };
      "org/gnome/desktop/interface" = {
        gtk-theme = config.gtk.theme.name;
        color-scheme = "prefer-dark";
      };
    };
    xdg.configFile =
      let
        gtk4 = "${config.gtk.theme.package}/share/themes/everforest/gtk-4.0";
        gtk3 = "${config.gtk.theme.package}/share/themes/everforest/gtk-3.0";
        gtk2 = "${config.gtk.theme.package}/share/themes/everforest/gtk-3.0";
      in
      {
        "gtk-4.0/assets".source = "${gtk4}/assets";
        "gtk-4.0/gtk.css".source = "${gtk4}/gtk.css";
        "gtk-4.0/gtk-dark.css".source = "${gtk4}/gtk-dark.css";
        "gtk-3.0/assets".source = "${gtk3}/assets";
        "gtk-3.0/gtk.css".source = "${gtk3}/gtk.css";
        "gtk-3.0/gtk-dark.css".source = "${gtk3}/gtk-dark.css";
      };
  };
}
