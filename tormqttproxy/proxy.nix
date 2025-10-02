{
  config,
  lib,
  pkgs,
  mqttBridgeAddress,
  mqttTopicPrefix,
  topics,
  ...
}:
let
  cfg = config.services.meshcore-mqtt-bridge;
  # Use the custom python3 with mqttproxy from the overlay
  python3WithMqtt = pkgs.python3.override {
    packageOverrides = final: prev: {
      meshcore = final.callPackage ./meshcore.nix { };
      mqttproxy = final.callPackage ./mqttproxy.nix {
        meshcore = final.meshcore;
      };
    };
  };
in
{
  options.services.meshcore-mqtt-bridge = {
    enable = lib.mkEnableOption "MeshCore MQTT Bridge service";

    mqttBroker = lib.mkOption {
      type = lib.types.str;
      description = "MQTT broker address (can be onion address)";
    };

    mqttPort = lib.mkOption {
      type = lib.types.port;
      default = 1883;
      description = "MQTT broker port";
    };

    mqttUsername = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "MQTT username";
    };

    mqttPasswordFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to file containing MQTT password";
    };

    mqttTopicPrefix = lib.mkOption {
      type = lib.types.str;
      default = "meshcore";
      description = "MQTT topic prefix";
    };

    meshcoreConnection = lib.mkOption {
      type = lib.types.enum [
        "serial"
        "tcp"
        "ble"
      ];
      default = "serial";
      description = "MeshCore connection type";
    };

    meshcoreAddress = lib.mkOption {
      type = lib.types.str;
      description = "MeshCore device address (serial port, IP, or BLE MAC)";
    };

    meshcorePort = lib.mkOption {
      type = lib.types.nullOr lib.types.port;
      default = null;
      description = "MeshCore TCP port (only for TCP connections)";
    };

    meshcoreBaudrate = lib.mkOption {
      type = lib.types.int;
      default = 115200;
      description = "Baudrate for serial connections";
    };

    meshcoreTimeout = lib.mkOption {
      type = lib.types.int;
      default = 30;
      description = "Operation timeout in seconds";
    };

    meshcoreAutoFetchRestartDelay = lib.mkOption {
      type = lib.types.int;
      default = 10;
      description = "Delay before restarting auto-fetch after NO_MORE_MSGS (1-60 seconds)";
    };

    meshcoreMessageInitialDelay = lib.mkOption {
      type = lib.types.float;
      default = 15.0;
      description = "Initial delay before sending first message (0.0-60.0 seconds)";
    };

    meshcoreMessageSendDelay = lib.mkOption {
      type = lib.types.float;
      default = 15.0;
      description = "Delay between consecutive message sends (0.0-60.0 seconds)";
    };

    meshcoreEvents = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "CONTACT_MSG_RECV"
        "CHANNEL_MSG_RECV"
        "DEVICE_INFO"
        "BATTERY"
        "CONNECTED"
        "DISCONNECTED"
        "ADVERTISEMENT"
      ];
      description = "List of MeshCore event types to subscribe to";
    };

    logLevel = lib.mkOption {
      type = lib.types.enum [
        "DEBUG"
        "INFO"
        "WARNING"
        "ERROR"
        "CRITICAL"
      ];
      default = "INFO";
      description = "Logging level";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "meshcore-mqtt";
      description = "User to run the service as";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "meshcore-mqtt";
      description = "Group to run the service as";
    };
  };

  config = {
    services.mosquitto = {
      enable = true;
      persistence = false;
      bridges.tor = {
        addresses = [
          {
            address = "127.0.0.1";
            port = 18830;
          }
        ];
        topics = topics;
      };
    };

    services.tor = {
      enable = true;
      relay.onionServices.mqtt = {
        version = 3;
        map = [
          {
            port = 1883;
            target = {
              addr = "[::1]";
              port = 1883;
            };
          }
        ];
      };
      client.enable = true;
      torsocks.enable = true;
    };

    networking.firewall.enable = true;
    # Only enable for debugging!
    # networking.firewall.allowedTCPPorts = [ 1883 ];

    systemd.services.mqtt-tor-proxy = {
      description = "MQTT Tor proxy via socat";
      after = [ "tor.service" ];
      wants = [ "tor.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = "${pkgs.socat}/bin/socat TCP-LISTEN:18830,reuseaddr,fork SOCKS5:127.0.0.1:${mqttBridgeAddress}:1883,socksport=9050";
        Restart = "always";
        User = "nobody";
      };
    };

    # Enable the meshcore-mqtt-bridge service
    services.meshcore-mqtt-bridge = {
      enable = true;
      mqttBroker = "localhost";
      mqttPort = 1883;
      meshcoreConnection = "serial";
      meshcoreAddress = "/dev/ttyUSB0";
      # Uncomment and adjust these if needed:
      # meshcoreBaudrate = 115200;
      logLevel = "DEBUG";
      mqttTopicPrefix = mqttTopicPrefix;
    };

    users.users.${cfg.user} = lib.mkIf cfg.enable {
      isSystemUser = true;
      group = cfg.group;
      description = "MeshCore MQTT Bridge service user";
      # Add user to dialout group for serial port access
      extraGroups = lib.optional (cfg.meshcoreConnection == "serial") "dialout";
    };

    users.groups.${cfg.group} = lib.mkIf cfg.enable { };

    systemd.services.meshcore-mqtt-bridge = lib.mkIf cfg.enable {
      description = "MeshCore MQTT Bridge Service";
      after = [
        "network-online.target"
        "mosquitto.service"
      ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        Restart = "always";
        RestartSec = "10s";

        # Security hardening
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        NoNewPrivileges = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
        RestrictRealtime = true;
        RestrictNamespaces = true;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
          "AF_NETLINK"
        ];

        # Allow access to serial devices if needed
        DeviceAllow = lib.mkIf (cfg.meshcoreConnection == "serial") [
          "/dev/ttyUSB0 rwm"
          "/dev/ttyACM0 rwm"
        ];

        # Environment variables
        Environment = [
          "LOG_LEVEL=${cfg.logLevel}"
          "MQTT_BROKER=${cfg.mqttBroker}"
          "MQTT_PORT=${toString cfg.mqttPort}"
          "MQTT_TOPIC_PREFIX=${cfg.mqttTopicPrefix}"
          "MESHCORE_CONNECTION=${cfg.meshcoreConnection}"
          "MESHCORE_ADDRESS=${cfg.meshcoreAddress}"
          "MESHCORE_BAUDRATE=${toString cfg.meshcoreBaudrate}"
          "MESHCORE_TIMEOUT=${toString cfg.meshcoreTimeout}"
          "MESHCORE_AUTO_FETCH_RESTART_DELAY=${toString cfg.meshcoreAutoFetchRestartDelay}"
          "MESHCORE_MESSAGE_INITIAL_DELAY=${toString cfg.meshcoreMessageInitialDelay}"
          "MESHCORE_MESSAGE_SEND_DELAY=${toString cfg.meshcoreMessageSendDelay}"
          "MESHCORE_EVENTS=${lib.concatStringsSep "," cfg.meshcoreEvents}"
        ]
        ++ lib.optional (cfg.mqttUsername != null) "MQTT_USERNAME=${cfg.mqttUsername}"
        ++ lib.optional (cfg.meshcorePort != null) "MESHCORE_PORT=${toString cfg.meshcorePort}";

        # Load password from file if provided
        EnvironmentFile = lib.mkIf (cfg.mqttPasswordFile != null) cfg.mqttPasswordFile;

        ExecStart = "${
          python3WithMqtt.withPackages (ps: [ ps.mqttproxy ])
        }/bin/python -m meshcore_mqtt.main --env";
      };
    };
  };
}
