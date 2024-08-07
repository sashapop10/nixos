{ prev, ... }:

let
  apc-extension = builtins.fetchGit {
    url = "https://github.com/drcika/apc-extension.git";
    rev = "d4cc908bf2869fe354aa0c103bab063aa09fd491";
  };
in prev.vscode.overrideAttrs (attrs: {
  buildInputs = attrs.buildInputs ++ [ prev.bun ];
  postInstall = ''
    cd $out
    mkdir apc-extension
    sed '1d' ${apc-extension}/src/patch.ts >> $out/apc-extension/patch.ts
    sed "s%require.main!.filename%'$out/lib/vscode/resources/app/out/dummy'%g" -i  $out/apc-extension/patch.ts
    sed "s%vscode.window.showErrorMessage(%throw new Error(installationPath + %g" -i  $out/apc-extension/patch.ts
    sed "s%promptRestart();%%g" -i  $out/apc-extension/patch.ts
    sed '1d' ${apc-extension}/src/utils.ts > $out/apc-extension/utils.ts
    ls $out/apc-extension >> log
    echo "import { install } from './patch.ts'; install({ extensionPath: '${apc-extension}' })" > $out/apc-extension/install.ts
    bun apc-extension/install.ts
  '';

  # desktopItem = let inherit (attrs.passthru) executableName longName;
  # in prev.makeDesktopItem {
  #   name = executableName;
  #   desktopName = longName;
  #   comment = "Code Editing. Redefined.";
  #   genericName = "Text Editor";
  #   exec = "${executableName} %F";
  #   icon = "vs${executableName}";
  #   startupNotify = true;
  #   startupWMClass = "Code";
  #   categories = [ "Utility" "TextEditor" "Development" "IDE" ];
  #   keywords = [ "vscode" ];
  #   actions.new-empty-window = {
  #     name = "New Empty Window";
  #     exec = "${executableName} --new-window %F";
  #     icon = "vs${executableName}";
  #   };
  # };
})
