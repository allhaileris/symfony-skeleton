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
            ])
          );
        }
      );
    in
    [
      phpForRuntimeWithXDebug
      pkgs.treefmt
      pkgs.nixfmt-rfc-style
      pkgs.gnumake
      pkgs.php82Extensions.curl
      pkgs.php82Packages.composer
    ];
in
pkgs.mkShell {
  inherit packages;
}

