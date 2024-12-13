{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  cfg = config.services.prometheus.exporters.nvidia_gpu;
  inherit (lib) mkOption types concatStringsSep;
in
{
  port = 9835;
  extraOpts = {
    webSystemdSocket = mkOption {
      type = types.bool;
      default = false;
      description = "Use systemd socket activation listeners instead of port listeners (Linux only).";
    };
    webConfigFile = mkOption {
      type = types.str;
      default = "";
      description = "Path to configuration file that can enable TLS or authentication.";
    };
    webNetwork = mkOption {
      type = types.str;
      default = "tcp";
      description = "Network type. Valid values are tcp4, tcp6 or tcp.";
    };
    webReadTimeout = mkOption {
      type = types.str;
      default = "10s";
      description = "Maximum duration before timing out read of the request.";
    };
    webReadHeaderTimeout = mkOption {
      type = types.str;
      default = "10s";
      description = "Maximum duration before timing out read of the request headers.";
    };
    webWriteTimeout = mkOption {
      type = types.str;
      default = "15s";
      description = "Maximum duration before timing out write of the response.";
    };
    webIdleTimeout = mkOption {
      type = types.str;
      default = "60s";
      description = "Maximum amount of time to wait for the next request when keep-alive is enabled.";
    };
    webTelemetryPath = mkOption {
      type = types.str;
      default = "/metrics";
      description = "Path under which to expose metrics.";
    };
    nvidiaSmiCommand = mkOption {
      type = types.str;
      default = "nvidia-smi";
      description = "Path or command to be used for the nvidia-smi executable.";
    };
    queryFieldNames = mkOption {
      type = types.str;
      default = "AUTO";
      description = "Comma-separated list of the query fields.";
    };
    logLevel = mkOption {
      type = types.str;
      default = "info";
      description = "Only log messages with the given severity or above.";
    };
    logFormat = mkOption {
      type = types.str;
      default = "logfmt";
      description = "Output format of log messages.";
    };
  };

  serviceOpts = {
    serviceConfig = {
      ExecStart = ''
        ${pkgs.nvidia_gpu_exporter}/bin/nvidia_gpu_exporter \
          --web.listen-address :${toString cfg.port} \
          --web.systemd-socket ${toString cfg.webSystemdSocket} \
          --web.config.file ${cfg.webConfigFile} \
          --web.network ${cfg.webNetwork} \
          --web.read-timeout ${cfg.webReadTimeout} \
          --web.read-header-timeout ${cfg.webReadHeaderTimeout} \
          --web.write-timeout ${cfg.webWriteTimeout} \
          --web.idle-timeout ${cfg.webIdleTimeout} \
          --web.telemetry-path ${cfg.webTelemetryPath} \
          --nvidia-smi-command ${cfg.nvidiaSmiCommand} \
          --query-field-names ${cfg.queryFieldNames} \
          --log.level ${cfg.logLevel} \
          --log.format ${cfg.logFormat}
      '';
      Environment = [
      ];
    };
  };
}
