let
  # this was taken from a gist which involved cross compilation. This is probably a weird thing to do.
  pkgsIntel = import <nixpkgs> {};
in
  final: prev: rec {
    inherit pkgsIntel;
    playdate-sdk = prev.callPackage ./playdate-sdk.nix {};
    gcc-arm-embedded = final.pkgs-unstable.gcc-arm-embedded-11;
  }
