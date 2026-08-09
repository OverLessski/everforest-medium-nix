{ lib }:
let
  supportedPlatforms = [
    "linux"
    "darwin"
  ];

  moduleGroups = [
    {
      file = ./bat.nix;
      themes = [
        {
          name = "bat";
          platforms = [ "linux" ];
        }
      ];
    }
    {
      file = ./fzf.nix;
      themes = [
        {
          name = "fzf";
          platforms = [ "linux" ];
        }
      ];
    }
    {
      file = ./gtk.nix;
      themes = [
        {
          name = "gtk";
          platforms = [ "linux" ];
        }
      ];
    }
    {
      file = ./yazi.nix;
      themes = [
        {
          name = "yazi";
          platforms = [ "linux" ];
        }
      ];
    }
    {
      file = ./zathura.nix;
      themes = [
        {
          name = "zathura";
          platforms = [ "linux" ];
        }
      ];
    }
  ];

  fail = message: throw "Invalid Home Manager Application Theme Catalog: ${message}";

  validateTheme =
    theme:
    let
      label =
        if builtins.isAttrs theme && theme ? name && builtins.isString theme.name then
          "`${theme.name}`"
        else
          "<unnamed>";
      unknownPlatforms =
        if builtins.isAttrs theme && theme ? platforms && builtins.isList theme.platforms then
          builtins.filter (platform: !(builtins.elem platform supportedPlatforms)) theme.platforms
        else
          [ ];
    in
    if !builtins.isAttrs theme then
      fail "each Application Theme must be an attribute set"
    else if !(theme ? name) || !builtins.isString theme.name || theme.name == "" then
      fail "${label} must have a non-empty string `name`"
    else if !(theme ? platforms) || !builtins.isList theme.platforms || theme.platforms == [ ] then
      fail "${label} must have at least one platform"
    else if !builtins.all builtins.isString theme.platforms then
      fail "${label} platforms must be strings"
    else if unknownPlatforms != [ ] then
      fail "${label} uses unsupported platforms: ${builtins.concatStringsSep ", " unknownPlatforms}"
    else
      theme;

  validateModuleGroup =
    group:
    let
      label =
        if builtins.isAttrs group && group ? file && builtins.isPath group.file then
          "`${builtins.toString group.file}`"
        else
          "<unnamed module>";
    in
    if !builtins.isAttrs group then
      fail "each module group must be an attribute set"
    else if !(group ? file) || !builtins.isPath group.file then
      fail "${label} must have a path-valued `file`"
    else if !builtins.pathExists group.file then
      fail "${label} references a missing module file"
    else if !(group ? themes) || !builtins.isList group.themes || group.themes == [ ] then
      fail "${label} must have at least one Application Theme"
    else
      group // { themes = map validateTheme group.themes; };

  validate =
    groups:
    let
      validatedGroups = map validateModuleGroup groups;
      moduleFiles = map (group: builtins.toString group.file) validatedGroups;
      themes = lib.concatMap (group: group.themes) validatedGroups;
      themeNames = map (theme: theme.name) themes;
      duplicatesIn =
        values:
        lib.unique (
          builtins.filter (
            value: builtins.length (builtins.filter (candidate: candidate == value) values) > 1
          ) values
        );
      duplicateModuleFiles = duplicatesIn moduleFiles;
      duplicateThemeNames = duplicatesIn themeNames;
    in
    if !builtins.isList groups then
      fail "catalog must be a list"
    else if duplicateModuleFiles != [ ] then
      fail "duplicate module files: ${builtins.concatStringsSep ", " duplicateModuleFiles}"
    else if duplicateThemeNames != [ ] then
      fail "duplicate Application Theme names: ${builtins.concatStringsSep ", " duplicateThemeNames}"
    else
      validatedGroups;

  groups = validate moduleGroups;
  themes = lib.concatMap (group: group.themes) groups;

  platformName =
    hostPlatform:
    if hostPlatform.isLinux then
      "linux"
    else if hostPlatform.isDarwin then
      "darwin"
    else
      throw "everforest Home Manager module supports Linux and Darwin only; got `${hostPlatform.system}`";
in
{
  moduleDescriptors = map (group: {
    inherit (group) file;
    applicationThemeNames = map (theme: theme.name) group.themes;
  }) groups;

  ineligibleThemeNamesFor =
    hostPlatform:
    let
      platform = platformName hostPlatform;
    in
    map (theme: theme.name) (builtins.filter (theme: !(builtins.elem platform theme.platforms)) themes);
}
