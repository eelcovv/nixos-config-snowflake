{ options
, config
, lib
, pkgs
, ...
}:
with lib;
with lib.my; {
  options.modules.desktop.extra.ibus = {
    enable = mkBoolOpt false;
  };

  config = mkIf config.modules.desktop.extra.ibus.enable {
    i18n.inputMethod = {
      enabled = "ibus";
      ibus.engines = with pkgs.ibus-engines; [ libpinyin hangul mozc ];
    };

    environment.variables = mkMerge [
      {
        GTK_IM_MODULE = "ibus";
        QT_IM_MODULE = "ibus";
        XMODIFIERS = "@im=ibus";
        SDL_IM_MODULE = "ibus";
      }

      (mkIf config.modules.desktop.terminal.kitty.enable {
        GLFW_IM_MODULE = "ibus";
      })
    ];
  };
}
