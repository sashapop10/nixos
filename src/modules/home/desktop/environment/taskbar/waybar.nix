{ config, lib, pkgs, myLib, inputs, ... }:
let
  inherit (config.my.home.colorscheme) colors;
  swayCfg = config.wayland.windowManager.sway;
  hyprlandCfg = config.wayland.windowManager.hyprland;
  mkScriptJson = myLib.mkWaybarScriptJson pkgs;
  mkScript = myLib.mkWaybarScript pkgs;
  cfg = config.my.home.desktop;
in {
  config = lib.mkIf (cfg.enable && cfg.taskbar == "waybar") {
    systemd.user.services.waybar.Unit.StartLimitBurst = 30;
    programs.waybar = {
      enable = true;
      systemd.enable = true;
      package = pkgs.waybar.overrideAttrs (o: {
        mesonFlags = (o.mesonFlags or [ ]) ++ [ "-Dexperimental=true" ];
      });

      settings.primary = {
        exclusive = false;
        passthrough = false;
        position = "bottom";
        height = 40;
        margin = "6";

        modules-left = [ "custom/menu" ]
          ++ (lib.optionals swayCfg.enable [ "sway/workspaces" "sway/mode" ])
          ++ (lib.optionals hyprlandCfg.enable [
            "hyprland/workspaces"
            "hyprland/submap"
            "hyprland/language"
          ]) ++ [ "custom/currentplayer" "custom/player" ];

        modules-center = let isGPU = t: lib.hasInfix t config.my.hardware.gpu;
        in [ "cpu" ] # -_-
        ++ (lib.optionals (isGPU "nvidia") [ "custom/gpu-nvidia" ])
        ++ (lib.optionals (isGPU "amd") [ "custom/gpu-amd" ])
        ++ [ "memory" "disk" "clock" "pulseaudio" "battery" "bluetooth" ];

        modules-right = [
          "custom/rfkill"
          "network"
          "tray"
          "custom/hostname"

        ];

        "hyprland/workspaces" = { sort-by-number = true; };

        "hyprland/language" = {
          format-en = "US";
          format-ru = "RU";
          tooltip = false;
        };

        clock = {
          interval = 1;
          format = "{:%d/%m     %H:%M}";
          format-alt = "{:%Y-%m-%d     %H:%M:%S %z}";
          on-click-left = "mode";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
          calendar = {
            mode = "month";
            on-scroll = 1;
            format = {
              months = "<span color='${colors.primary}'><b>{}</b></span>";
              days = "<span color='${colors.on_surface}'><b>{}</b></span>";
              weekdays = "<span color='${colors.secondary}'><b>{}</b></span>";
              today = "<span color='${colors.primary}'><b>{}</b></span>";
            };
          };
          actions = {
            on-scroll-up = "shift_up";
            on-scroll-down = "shift_down";
          };
        };

        cpu = {
          format = "  ";
          tooltip-format = "{usage}%";
        };

        memory = {
          format = "  ";
          interval = 30;
          tooltip-format = "{percentage}%";
        };

        disk = {
          interval = 30;
          format = "󰋊  ";
          tooltip-format = "{used}/{total}";
        };

        pulseaudio = {
          on-click = lib.getExe pkgs.pavucontrol;
          format = "{icon}  {volume}%";
          format-muted = "   0%";
          format-icons = {
            headphone = "󰋋 ";
            headset = "󰋎 ";
            portable = " ";
            default = [ " " " " " " ];
          };
        };

        idle_inhibitor = {
          format = "{icon}";
          format-icons = {
            activated = "󰒳";
            deactivated = "󰒲";
          };
        };

        battery = {
          bat = "BAT0";
          interval = 10;
          format-icons = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
          format = "{icon} {capacity}%";
          format-charging = " {capacity}%";
          format-discharging = "{icon} {capacity}%";
          format-alt = "{time} {icon}";
          onclick = "";
          states = {
            good = 95;
            warning = 30;
            critical = 20;
          };
        };

        "sway/window" = { max-length = 20; };

        network = {
          interval = 3;
          max-length = 20;
          format-wifi = "    {essid}";
          format-ethernet = "󰈁   Connected";
          format-disconnected = "󰇨   Disconnected";
          on-click = "nm-connection-editor";
          tooltip-format = ''
            {ifname} = {ipaddr}/{cidr}
            U: {bandwidthUpBits} / D: {bandwidthDownBits}'';
        };

        bluetooth = {
          format = "󰂯";
          max-length = 35;
          on-click = "blueman-manager";
          format-disabled = "󰂲  NaN";
          format-connected = "󰂱   {device_alias}";
          format-connected-battery =
            "󰂱   {device_alias} (󰥉 {device_battery_percentage}%)";

          tooltip-format-disabled = "bluetooth off";
          tooltip-format = "{controller_alias}	{controller_address} ({status})";
          tooltip-format-connected = ''
            {controller_alias}	{controller_address} ({status})
            {device_enumerate}'';

          tooltip-format-enumerate-connected =
            "{device_alias}	{device_address}";

          tooltip-format-enumerate-connected-battery =
            "{device_alias}	{device_address}	({device_battery_percentage}%)";
        };

        "custom/gpu-amd" = {
          interval = 30;
          exec = mkScript {
            script = "cat /sys/class/drm/card0/device/gpu_busy_percent";
          };
          format = "󰒋  ";
          tooltip-format = "{}%";
        };

        "custom/gpu-nvidia" = {
          interval = 30;
          exec = mkScript {
            deps = [ "nvidia-smi" ];
            script =
              "nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits";
          };
          format = "󰒋  ";
          tooltip-format = "{}%";
        };

        "custom/menu" = {
          interval = 1;
          return-type = "json";
          exec = mkScriptJson {
            deps = lib.optional hyprlandCfg.enable hyprlandCfg.package;
            text = "";
            tooltip = ''$(grep PRETTY_NAME /etc/os-release | cut -d '"' -f2)'';
          };

          on-click = if config.programs.wofi.enable then
            mkScript { script = "pkill wofi ; wofi --show drun"; }
          else if config.programs.rofi.enable then
            mkScript { script = "pkill rofi ; rofi -show drun -show-icons"; }
          else
            "false";
        };

        "custom/hostname" = {
          exec = mkScript { script = ''echo "$USER@$HOSTNAME"''; };
          on-click = mkScript { script = "systemctl --user restart waybar"; };
        };

        "custom/currentplayer" = {
          interval = 2;
          return-type = "json";
          format = "{icon}{}";

          exec = mkScriptJson {
            deps = [ pkgs.playerctl ];
            alt = "$player";
            tooltip = "$player ($count available)";
            text = "$more";
            pre = ''
              player="$(playerctl status -f "{{playerName}}" 2>/dev/null || echo "No player active" | cut -d '.' -f1)"
              count="$(playerctl -l 2>/dev/null | wc -l)"
              if ((count > 1)); then
                more=" +$((count - 1))"
              else
                more=""
              fi
            '';
          };

          format-icons = {
            "No player active" = " ";
            "Celluloid" = "󰎁 ";
            "spotify" = "󰓇 ";
            "ncspot" = "󰓇 ";
            "qutebrowser" = "󰖟 ";
            "firefox" = " ";
            "discord" = " 󰙯 ";
            "sublimemusic" = " ";
            "kdeconnect" = "󰄡 ";
            "chromium" = " ";
          };
        };

        "custom/rfkill" = {
          interval = 1;
          exec-if = mkScript {
            deps = [ pkgs.util-linux ];
            script = "rfkill | grep '<blocked>'";
          };
        };

        "custom/player" = {
          return-type = "json";
          interval = 2;
          max-length = 20;
          format = "{icon} {}";
          format-icons = {
            "Playing" = "󰐊";
            "Paused" = "󰏤 ";
            "Stopped" = "󰓛";
          };

          exec-if = mkScript {
            deps = [ pkgs.playerctl ];
            script = "playerctl status 2>/dev/null";
          };

          exec = let
            format = ''
              {"text": "{{title}} - {{artist}}", "alt": "{{status}}", "tooltip": "{{title}} - {{artist}} ({{album}})"}'';
          in mkScript {
            deps = [ pkgs.playerctl ];
            script = "playerctl metadata --format '${format}' 2>/dev/null";
          };

          on-click-middle = mkScript {
            deps = [ pkgs.playerctl ];
            script = "playerctl play-pause";
          };

          on-click-right = mkScript {
            deps = [ pkgs.playerctl ];
            script = "playerctl next";
          };

          on-click = mkScript {
            deps = [ pkgs.playerctl ];
            script = "playerctl prev";
          };
        };
      };

      style = let
        inherit (inputs.nix-colors.lib.conversions) hexToRGBString;
        rgb = c: o: "rgba(${hexToRGBString "," (lib.removePrefix "#" c)},${o})";
      in ''
        * {
          font-family: ${cfg.fonts.regular.name}, ${cfg.fonts.monospace.name};
          font-size: ${toString cfg.fonts.regular.size}pt;
          padding: 0;
          margin: 0 0.4em;
        }

        window#waybar {
          padding: 0;
          border-radius: 0.5em;
          background-color: ${rgb colors.surface "0.7"};
          color: ${colors.on_surface};
        }

        .modules-left {
          margin-left: -0.65em;
        }

        .modules-right {
          margin-right: -0.65em;
        }

        #workspaces button {
          background-color: ${colors.surface};
          color: ${colors.on_surface};
          padding-left: 0.4em;
          padding-right: 0.4em;
          margin-top: 0.15em;
          margin-bottom: 0.15em;
        }

        #workspaces button.hidden {
          background-color: ${colors.surface};
          color: ${colors.on_surface_variant};
        }

        #workspaces button.focused,
        #workspaces button.active {
          background-color: ${colors.primary};
          color: ${colors.on_primary};
        }

        #clock {
          padding-right: 1em;
          padding-left: 1em;
          border-radius: 0.5em;
        }

        #custom-menu {
          background-color: ${colors.surface_container};
          color: ${colors.primary};
          padding-right: 1.5em;
          padding-left: 1em;
          margin-right: 0;
          border-radius: 0.5em;
        }

        #custom-hostname {
          background-color: ${colors.surface_container};
          color: ${colors.primary};
          padding-right: 1em;
          padding-left: 1em;
          margin-left: 0;
          border-radius: 0.5em;
        }

        #custom-currentplayer {
          padding-right: 0;
        }

        #tray {
          color: ${colors.on_surface};
        }

        #custom-gpu, #cpu, #memory {
          margin-left: 0.05em;
          margin-right: 0.55em;
        }
      '';
    };
  };
}
