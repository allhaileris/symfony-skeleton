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
            ])
          );
        }
      );
    in
    [
      pkgs.postgresql_16
      pkgs.nixfmt-rfc-style
      pkgs.gnumake
      phpForRuntimeWithXDebug
      pkgs.php82Extensions.curl
      pkgs.php82Packages.composer
    ];
in
pkgs.mkShell {
  inherit packages;

  shellHook = ''
    export COMPOSER_CACHE_DIR=$(pwd)/var/cache/composer
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
