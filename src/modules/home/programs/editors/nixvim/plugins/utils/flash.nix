{ config, lib, ... }:

# Moving between search
# https://github.com/folke/flash.nvim/
let cfg = config.programs.nixvim;
in {
  config.programs.nixvim = lib.mkIf cfg.enable {
    plugins.flash = {
      enable = true;
      settings = {
        jump.autojump = true;
        search.mode = "fuzzy";
        labels = "asdfghjklqwertyuiopzxcvbnm";
        label = {
          uppercase = false;
          rainbow = {
            enabled = false;
            shade = 5;
          };
        };
      };
    };

    keymaps = [
      {
        mode = [ "n" "x" "o" ];
        key = "s";
        action = "<cmd>lua require('flash').jump()<cr>";
        options.desc = "Flash";
      }

      {
        mode = [ "n" "x" "o" ];
        key = "S";
        action = "<cmd>lua require('flash').treesitter()<cr>";
        options.desc = "Flash Treesitter";
      }

      {
        mode = "o";
        key = "r";
        action = "<cmd>lua require('flash').remote()<cr>";
        options.desc = "Remote Flash";
      }

      {
        mode = [ "x" "o" ];
        key = "R";
        action = "<cmd>lua require('flash').treesitter_search()<cr>";
        options.desc = "Treesitter Search";
      }
    ];
  };

}
