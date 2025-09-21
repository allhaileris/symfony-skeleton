let
  nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/nixos-25.05";
  postgresDirectory = ".data/postgres";

  pkgs = import nixpkgs {
    config = { };
    overlays = [ ];
  };

  packages =
    let
      phpForRuntimeWithXDebug = (
        pkgs.php82.buildEnv {
          extensions = (
            { enabled, all }:
            enabled
            ++ (with all; [
              xdebug
              amqp
            ])
          );
        }
      );
    in
    [
      pkgs.postgresql_16
      pkgs.rabbitmq-server
      pkgs.nixfmt-rfc-style
      pkgs.gnumake
      phpForRuntimeWithXDebug
      pkgs.php82Extensions.curl
      # composer check-platform-reqs
      (pkgs.php82.withExtensions ({ enabled, all }: enabled ++ [ all.amqp ])).packages.composer
    ];
in
pkgs.mkShell {
  inherit packages;

  shellHook = ''
    export COMPOSER_CACHE_DIR=$(pwd)/var/cache/composer
    export RABBITMQ_CONFIG_FILE=$(pwd)/.dev/rabbitmq.conf
    export RABBITMQ_MNESIA_BASE=$(pwd)/.data/rabbitmq
    export RABBITMQ_LOGS=$(pwd)/var/log/rabbitmq.log

    mkdir -p $(pwd)/var/cache/composer

    if [ ! -d $(pwd)/var/log ]; then
       mkdir -p $(pwd)/var/log
    fi

    # https://yannesposito.com/posts/0024-replace-docker-compose-with-nix-shell/index.html
    if [ ! -d ${postgresDirectory} ]; then
      mkdir -p ${postgresDirectory}
      initdb -D ${postgresDirectory}
      pg_ctl -D ${postgresDirectory} -l $(pwd)/var/log/postgres.log -o "--unix_socket_directories='$PWD'" start
      createdb app
      pg_ctl -D ${postgresDirectory} stop
    fi
  '';
}
