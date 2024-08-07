{ config, pkgs, lib, outputs, ... }:
let
  rgb = color: "rgb(${lib.removePrefix "#" color})";
  rgba = color: alpha: "rgba(${lib.removePrefix "#" color}${alpha})";
  getHostname = x: lib.last (lib.splitString "@" x);
  remoteColorschemes = lib.mapAttrs' (n: v: {
    name = getHostname n;
    value =
      v.config.colorscheme.rawColorscheme.colors.${config.colorscheme.mode};
  }) outputs.homeConfigurations;

  # Make sure it's using the same hyprland package as we are
  hyprbars = (pkgs.hyprbars.override {
    hyprland = config.wayland.windowManager.hyprland.package;
  }).overrideAttrs (old: {
    # Yeet the initialization notification (I hate it)
    postPatch = (old.postPatch or "") + ''
      ${lib.getExe pkgs.gnused} -i '/Initialized successfully/d' main.cpp
    '';
  });
in {
  wayland.windowManager.hyprland = {
    plugins = [ hyprbars ];
    settings = {
      "plugin:hyprbars" = {
        bar_height = 25;
        bar_color = rgba config.colorscheme.colors.surface "dd";
        "col.text" = rgb config.colorscheme.colors.primary;
        bar_text_font = config.fontProfiles.regular.family;
        bar_text_size = 14;
        bar_part_of_window = true;
        bar_precedence_over_border = true;
        hyprbars-button = let
          closeAction = "hyprctl dispatch killactive";
          maximizeAction = "hyprctl dispatch fullscreen 1";

          isOnSpecial = ''
            hyprctl activewindow -j | jq -re 'select(.workspace.name == "special")' >/dev/null'';
          moveToSpecial = "hyprctl dispatch movetoworkspacesilent special";
          moveToActive =
            "hyprctl dispatch movetoworkspacesilent name:$(hyprctl -j activeworkspace | jq -re '.name')";
          minimizeAction =
            "${isOnSpecial} && ${moveToActive} || ${moveToSpecial}";
        in [
          # Red close button
          "${rgb config.colorscheme.harmonized.red},14,,${closeAction}"
          # Yellow "minimize" (send to special workspace) button
          "${rgb config.colorscheme.harmonized.yellow},14,,${maximizeAction}"
          # Green "maximize" (fullscreen) button
          "${rgb config.colorscheme.harmonized.green},14,,${minimizeAction}"
        ];
      };

      windowrulev2 = [
        "plugin:hyprbars:bar_color ${
          rgba config.colorscheme.colors.primary "ee"
        }, focus:1"
        "plugin:hyprbars:title_color ${
          rgb config.colorscheme.colors.on_primary
        }, focus:1"
      ] ++ (lib.flatten (lib.mapAttrsToList (name: colors: [
        "plugin:hyprbars:bar_color ${
          rgba colors.primary_container "dd"
        }, title:^(\\[${name}\\])"
        "plugin:hyprbars:title_color ${
          rgb colors.on_primary_container
        }, title:^(\\[${name}\\])"

        "plugin:hyprbars:bar_color ${
          rgba colors.primary "ee"
        }, title:^(\\[${name}\\]), focus:1"
        "plugin:hyprbars:title_color ${
          rgb colors.on_primary
        }, title:^(\\[${name}\\]), focus:1"
      ]) remoteColorschemes));
    };
  };
}
