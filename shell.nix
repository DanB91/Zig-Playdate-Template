{ pkgs ? import <nixpkgs> { overlays = [ (import ./nix/playdate-sdk/overlay.nix) ]; } }:
  pkgs.mkShell {
    nativeBuildInputs = with pkgs.buildPackages; [ zig playdate-sdk ];
    shellHook = ''
      export PLAYDATE_SDK_PATH="${pkgs.playdate-sdk.outPath}"
    '';
}
