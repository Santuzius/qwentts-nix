self:
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.qwentts;
in
{
  options.services.qwentts = {
    enable = lib.mkEnableOption "the Qwen3-TTS speech server as a systemd user service";

    package = lib.mkOption {
      type = lib.types.package;
      default = self.packages.${pkgs.stdenv.hostPlatform.system}.default;
      defaultText = lib.literalExpression "qwentts-nix.packages.\${system}.default";
      description = "The qwentts.cpp package to run.";
    };

    model = lib.mkOption {
      type = lib.types.str;
      default = "%h/.local/share/qwentts/models/qwen-talker-0.6b-customvoice-Q8_0.gguf";
      description = "Talker GGUF. Systemd specifiers such as %h are expanded.";
    };

    codec = lib.mkOption {
      type = lib.types.str;
      default = "%h/.local/share/qwentts/models/qwen-tokenizer-12hz-Q8_0.gguf";
      description = "Codec GGUF. Systemd specifiers such as %h are expanded.";
    };

    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Listen address.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = "Listen port.";
    };

    device = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "Vulkan0";
      description = "Compute device. Null lets the server pick the best one.";
    };

    autoStart = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Start the service with the user session.";
    };

    environment = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      example = {
        VK_DRIVER_FILES = "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.json";
      };
      description = "Environment of the service, for example to restrict Vulkan to one GPU.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.user.services.qwentts = {
      description = "Qwen3-TTS speech server";
      wantedBy = lib.optional cfg.autoStart "default.target";
      inherit (cfg) environment;
      serviceConfig = {
        ExecStart = lib.concatStringsSep " " (
          [
            (lib.getExe cfg.package)
            "--model"
            cfg.model
            "--codec"
            cfg.codec
            "--host"
            cfg.host
            "--port"
            (toString cfg.port)
          ]
          ++ lib.optionals (cfg.device != null) [
            "--device"
            cfg.device
          ]
        );
        Restart = "on-failure";
      };
    };
  };
}
