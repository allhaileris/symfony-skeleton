let
  nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/nixos-25.05";

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
}
