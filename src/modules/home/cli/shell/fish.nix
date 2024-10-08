{ config, lib, pkgs, ... }:

let
  shellcolor = "${pkgs.shellcolord}/bin/shellcolor";
  cfg = config.my.home.cli.shell;
in {
  config.programs.fish = lib.mkIf (cfg.type == "fish") {
    enable = true;
    shellAbbrs = cfg.abbrs;
    shellAliases = cfg.aliases;
    functions = {
      fish_greeting = ""; # Disable greeting
      nvimrg = lib.mkIf # Grep using ripgrep and pass to nvim
        (config.programs.nixvim.enable && config.programs.ripgrep.enable)
        "nvim -q (rg --vimgrep $argv | psub)";

      # Merge history upon doing up-or-search
      # This lets multiple fish instances share history
      up-or-search = ''
        if commandline --search-mode
          commandline -f history-search-backward
          return
        end
        if commandline --paging-mode
          commandline -f up-line
          return
        end
        set -l lineno (commandline -L)
        switch $lineno
          case 1
            commandline -f history-search-backward
            history merge
          case '*'
            commandline -f up-line
        end
      '';

      # Integrate ssh with shellcolord
      ssh = lib.mkIf config.programs.shellcolor.enable ''
        ${shellcolor} disable $fish_pid
        # Check if kitty is available
        if set -q KITTY_PID && set -q KITTY_WINDOW_ID && type -q -f kitty
          kitty +kitten ssh $argv
        else
          command ssh $argv
        end
        ${shellcolor} enable $fish_pid
        ${shellcolor} apply $fish_pid
      '';
    };

    interactiveShellInit = ''
      # Open command buffer in vim when alt+e is pressed
      bind \ee edit_command_buffer

      # kitty integration
      set --global KITTY_INSTALLATION_DIR "${pkgs.kitty}/lib/kitty"
      set --global KITTY_SHELL_INTEGRATION enabled
      source "$KITTY_INSTALLATION_DIR/shell-integration/fish/vendor_conf.d/kitty-shell-integration.fish"
      set --prepend fish_complete_path "$KITTY_INSTALLATION_DIR/shell-integration/fish/vendor_completions.d"

      # Use vim bindings and cursors
      # fish_vi_key_bindings
      set fish_cursor_default     block      blink
      set fish_cursor_insert      line       blink
      set fish_cursor_replace_one underscore blink
      set fish_cursor_visual      block

      # Use terminal colors
      set -U fish_color_autosuggestion      brblack
      set -U fish_color_cancel              -r
      set -U fish_color_command             brgreen
      set -U fish_color_comment             brmagenta
      set -U fish_color_cwd                 green
      set -U fish_color_cwd_root            red
      set -U fish_color_end                 brmagenta
      set -U fish_color_error               brred
      set -U fish_color_escape              brcyan
      set -U fish_color_history_current     --bold
      set -U fish_color_host                normal
      set -U fish_color_match               --background=brblue
      set -U fish_color_normal              normal
      set -U fish_color_operator            cyan
      set -U fish_color_param               brblue
      set -U fish_color_quote               yellow
      set -U fish_color_redirection         bryellow
      set -U fish_color_search_match        'bryellow' '--background=brblack'
      set -U fish_color_selection           'white' '--bold' '--background=brblack'
      set -U fish_color_status              red
      set -U fish_color_user                brgreen
      set -U fish_color_valid_path          --underline
      set -U fish_pager_color_completion    normal
      set -U fish_pager_color_description   yellow
      set -U fish_pager_color_prefix        'white' '--bold' '--underline'
      set -U fish_pager_color_progress      'brwhite' '--background=cyan'
    '';
  };
}
