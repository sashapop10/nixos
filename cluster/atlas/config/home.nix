{ pkgs, config, ... }: {
  my.system.users.${config.my.system.admin}.home = {
    desktop = {
      enable = true;
      isWayland = true;
      wallpaper = pkgs.wallpaper-ship-in-storm;
      manager = "hyprland";
      locker = "swaylock";
      explorer = "thunar";
      taskbar = "waybar";
      terminal = "kitty";
      launcher = "wofi";
      notifier = "mako";
      idle = "swayidle";

      fonts = {
        monospace.size = 14;
        regular.size = 14;
      };

      exec = [
        # Trash apps without tray flag
        "[workspace name:0 silent] zapzap ; sleep 2; hyprctl dispatch closewindow zapzap"
        "[workspace name:0 silent] thunderbird"

        # Worspace bound apps
        "[workspace special silent] kitty"
        "[workspace 1 silent] silent-code"
        "[workspace 2 silent] firefox-developer-edition"

        # XM4 Autoconnect fix
        ''sleep 2 && echo "connect AC:80:0A:E3:3B:CE" | bluetoothctl''

        # Tray apps
        "sleep 5; vesktop --start-minimized"
        "telegram-desktop -startintray"
        "thunder -startintray"
      ];
    };

    cli = {
      enableTweaks = true;
      enableGitTweaks = true;
      enableScripts = true;
      shell.type = "fish";
    };

    programs = {
      # Editors
      vscode.enable = true;
      micro.enable = true;
      nixvim.enable = true;

      # Browsers
      firefox.enable = true;
      chrome.enable = true;

      # Social
      zapzap.enable = true;
      discord.enable = true;
      thunderbird.enable = true;
      telegram.enable = true;

      # Documents
      libreoffice.enable = true;
      zathura.enable = true;

      # Media
      oculante.enable = true;
      mpv.enable = true;

      # Dev
      postman.enable = true;

      # Other
      obsidian.enable = true;
      rustdesk.enable = true;
      gimp.enable = true;
    };

    services = {
      kdeconnect.enable = true;
      nix-index.enable = true;
      waypipe.enable = true;
    };
  };
}
