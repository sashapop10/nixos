{ config, pkgs, ... }:

{
  fonts.packages = with pkgs; [
    nerdfonts
    noto-fonts
    noto-fonts-cjk
    roboto
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    dina-font
    proggyfonts
    iosevka-bin
  ];

  fonts.fontconfig = {
    antialias = true;
    hinting.enable = false;
    subpixel.rgba = "none";
    subpixel.lcdfilter = "none";
  };
}