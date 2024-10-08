{ pkgs, inputs, lib, config, ... }:

let cfg = config.my.home;
in {
  options.my.home.programs.firefox.enable =
    lib.mkEnableOption "Enable Firefox.";

  config.programs.firefox =
    lib.mkIf (cfg.desktop.enable && cfg.programs.firefox.enable) {
      enable = true;
      package = pkgs.firefox-devedition-bin;
      profiles.dev-edition-default = {
        id = 0;
        name = "dev-edition-default";
        isDefault = true;

        search = {
          force = true;
          default = "Google";
          privateDefault = "DuckDuckGo";
          order = [ "Google" "Yandex" ];
          engines = {
            "Bing".metaData.hidden = true;
            "Yandex" = {
              definedAliases = [ "@ya" "@yandex" ];
              iconUpdateURL = "https://ya.ru/favicon.ico";
              urls =
                [{ template = "https://ya.ru/search?text={searchTerms}"; }];
            };
            "Youtube" = {
              iconUpdateURL = "https://youtube.ru/favicon.ico";
              definedAliases = [ "@you" "@youtube" ];
              urls = [{
                template =
                  "https://youtube.com/results?search_query={searchTerms}";
              }];
            };
            "Nix Packages" = {
              definedAliases = [ "@pkgs" "@nixpkgs" ];
              iconUpdateURL = "https://nixos.org/favicon.png";
              urls = [{
                template =
                  "https://search.nixos.org/packages?query={searchTerms}";
              }];
            };
            "Nix Options" = {
              definedAliases = [ "@opts" "@nixopts" ];
              iconUpdateURL = "https://nixos.org/favicon.png";
              urls = [{
                template =
                  "https://search.nixos.org/options?query={searchTerms}";
              }];
            };
            "Home Manager" = {
              definedAliases = [ "@hm" "@home" ];
              iconUpdateURL = "https://nixos.org/favicon.png";
              urls = [{
                template =
                  "https://home-manager-options.extranix.com?query={searchTerms}";
              }];
            };
            "Github" = {
              definedAliases = [ "@git" "@github" ];
              iconUpdateURL =
                "https://github.githubassets.com/favicons/favicon-dark.svg";
              urls = [{
                template =
                  "https://github.com/search?q={searchTerms}&type=code";
              }];
            };

            "Node" = {
              definedAliases = [ "@no" "@node" ];
              iconUpdateURL =
                "https://nodejs.org/static/images/favicons/favicon.png";
              urls = [{
                template =
                  "https://nodejs.org/en/search?q={searchTerms}&section=all";
              }];
            };
          };
        };

        bookmarks = [
          {
            name = "NIX";
            toolbar = true;
            bookmarks = [
              {
                name = "Language manual";
                url = "https://nix.dev/manual/nix/2.18/language/";
              }
              {
                name = "Library manual";
                url = "https://ryantm.github.io/nixpkgs";
              }
              {
                name = "Types manual";
                url = "https://nixos.wiki/wiki/Declaration";
              }
              {
                name = "Modules manual";
                url =
                  "https://nlewo.github.io/nixos-manual-sphinx/development/option-types.xml.html";
              }
              {
                name = "Syncthing";
                url = "http://127.0.0.1:8384";
              }
            ];
          }
          {
            name = "SEO";
            toolbar = true;
            bookmarks = [
              {
                name = "Whatwg Heading";
                url = "https://html.spec.whatwg.org/#heading-content";
              }
              {
                name = "Whatwg Phrasing";
                url = "https://html.spec.whatwg.org/#phrasing-content";
              }
              {
                name = "Whatwg microdata";
                url = "https://html.spec.whatwg.org/#introduction-7";
              }
              {
                name = "Schemaorg";
                url =
                  "https://developers.google.com/search/docs/appearance/structured-data/search-gallery";
              }
            ];
          }
        ];

        extensions = with inputs.firefox-addons.packages.${pkgs.system}; [
          # bitwarden
          sidebery
          plasma-integration
          ublock-origin
          return-youtube-dislikes
          (wappalyzer.overrideAttrs { meta.license.free = true; })
          sponsorblock
          simple-translate
          # (grammarly.overrideAttrs { meta.license.free = true; })
          (languagetool.overrideAttrs { meta.license.free = true; })
          youtube-shorts-block
        ];

        settings = {
          "browser.startup.homepage" = "about:home";
          "identity.fxaccounts.enabled" = true; # fx accounts
          "signon.rememberSignons" = true; # Disable "save password" prompt
          "browser.download.useDownloadDir" = true; # Don't ask for download dir
          "network.http.http3.enable" = false; # Disable quic

          # Disable irritating first-run stuff
          "browser.disableResetPrompt" = true;
          "browser.download.panel.shown" = true;
          "browser.feeds.showFirstRunUI" = false;
          "browser.messaging-system.whatsNewPanel.enabled" = false;
          "browser.rights.3.shown" = true;
          "browser.shell.checkDefaultBrowser" = false;
          "browser.shell.defaultBrowserCheckCount" = 1;
          "browser.startup.homepage_override.mstone" = "ignore";
          "browser.uitour.enabled" = false;
          "startup.homepage_override_url" = "";
          "trailhead.firstrun.didSeeAboutWelcome" = true;
          "browser.bookmarks.restore_default_bookmarks" = false;
          "browser.bookmarks.addedImportButton" = true;

          # Disable some telemetry
          "app.shield.optoutstudies.enabled" = false;
          "browser.discovery.enabled" = false;
          "browser.newtabpage.activity-stream.feeds.telemetry" = false;
          "browser.newtabpage.activity-stream.telemetry" = false;
          "browser.ping-centre.telemetry" = false;
          "datareporting.healthreport.service.enabled" = false;
          "datareporting.healthreport.uploadEnabled" = false;
          "datareporting.policy.dataSubmissionEnabled" = false;
          "datareporting.sessions.current.clean" = true;
          "devtools.onboarding.telemetry.logged" = false;
          "toolkit.telemetry.archive.enabled" = false;
          "toolkit.telemetry.bhrPing.enabled" = false;
          "toolkit.telemetry.enabled" = false;
          "toolkit.telemetry.firstShutdownPing.enabled" = false;
          "toolkit.telemetry.hybridContent.enabled" = false;
          "toolkit.telemetry.newProfilePing.enabled" = false;
          "toolkit.telemetry.prompted" = 2;
          "toolkit.telemetry.rejected" = true;
          "toolkit.telemetry.reportingpolicy.firstRun" = false;
          "toolkit.telemetry.server" = "";
          "toolkit.telemetry.shutdownPingSender.enabled" = false;
          "toolkit.telemetry.unified" = false;
          "toolkit.telemetry.unifiedIsOptIn" = false;
          "toolkit.telemetry.updatePing.enabled" = false;

          # Disable crappy home activity stream page
          "browser.newtabpage.activity-stream.feeds.topsites" = false;
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
          "browser.newtabpage.activity-stream.improvesearch.topSiteSearchShortcuts" =
            false;
          "browser.newtabpage.blocked" = lib.genAttrs [
            "26UbzFJ7qT9/4DhodHKA1Q==" # Youtube
            "4gPpjkxgZzXPVtuEoAL9Ig==" # Facebook
            "eV8/WsSLxHadrTL1gAxhug==" # Wikipedia
            "gLv0ja2RYVgxKdp0I5qwvA==" # Reddit
            "K00ILysCaEq8+bEqV/3nuw==" # Amazon
            "T9nJot5PurhJSy8n038xGA==" # Twitter
          ] (_: 1);

          # Harden
          "privacy.trackingprotection.enabled" = true;
          "dom.security.https_only_mode" = true;

          # Layout
          "browser.uiCustomization.state" = builtins.toJSON {
            currentVersion = 20;
            newElementCount = 5;
            dirtyAreaCache = [
              "nav-bar"
              "PersonalToolbar"
              "toolbar-menubar"
              "TabsToolbar"
              "widget-overflow-fixed-list"
            ];

            placements = {
              PersonalToolbar = [ "personal-bookmarks" ];
              toolbar-menubar = [ "menubar-items" ];
              widget-overflow-fixed-list = [ ];
              unified-extensions-area = [ ];
              TabsToolbar =
                [ "tabbrowser-tabs" "new-tab-button" "alltabs-button" ];
              nav-bar = [
                "back-button"
                "forward-button"
                "stop-reload-button"
                "urlbar-container"
                "downloads-button"
                "ublock0_raymondhill_net-browser-action"
                "_testpilot-containers-browser-action"
                "reset-pbm-toolbar-button"
                "unified-extensions-button"
              ];
            };

            seen = [
              "ublock0_raymondhill_net-browser-action"
              "_testpilot-containers-browser-action"
              "save-to-pocket-button"
              "developer-button"
            ];
          };
        };
      };
    };
}
