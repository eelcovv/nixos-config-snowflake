{ options, config, lib, pkgs, ... }:

let
  inherit (lib.attrsets) attrValues;
  inherit (lib.modules) mkIf;
in {
  options.modules.desktop.gnome = let inherit (lib.options) mkEnableOption;
  in { enable = mkEnableOption "modern desktop environment"; };

  config = mkIf config.modules.desktop.gnome.enable {
    modules.desktop = {
      type = "wayland";
      extensions.input-method = {
        enable = true;
        framework = "ibus";
      };
    };

    services.xserver.desktopManager.gnome.enable = true;
    services.greetd.settings.initial_session.command = "gnome-session";

    services.gnome = {
      gnome-keyring.enable = true;
      gnome-browser-connector.enable = true;
      sushi.enable = true;
    };

    programs.dconf.enable = true;
    services.udev = {
      packages = [ pkgs.gnome-settings-daemon ];
      extraRules = ''
        ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/scheduler}="none"
        ACTION=="add|change", KERNEL=="sd[a-z]|mmcblk[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
        ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
      '';
    };

    user.packages = attrValues {
      inherit (pkgs) dconf2nix gnome-disk-utility gnome-tweaks polari;
      inherit (pkgs.gnomeExtensions)
        appindicator blur-my-shell dash-to-dock gsconnect
        just-perfection 
        removable-drive-menu space-bar user-themes;
    };

    environment.sessionVariables = {
      ELECTRON_OZONE_PLATFORM_HINT = "auto";
      NIXOS_OZONE_WL = "1";
      MOZ_ENABLE_WAYLAND = "1";
    };

    # Enable chrome-gnome-shell in FireFox nightly (mozilla-overlay):
    home.file.chrome-gnome-shell = {
      target =
        ".mozilla/native-messaging-hosts/org.gnome.chrome_gnome_shell.json";
      source =
        "${pkgs.chrome-gnome-shell}/lib/mozilla/native-messaging-hosts/org.gnome.chrome_gnome_shell.json";
    };
  };
}
