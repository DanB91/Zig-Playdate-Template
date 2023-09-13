let
  # this was taken from a gist which involved cross compilation. This is probably a weird thing to do.
  pkgsIntel = import <nixpkgs> {};
in
  final: prev: rec {
    inherit pkgsIntel;

    # This always outputs x86_64 binaries. I setup binfmt_misc in my 
    # system config to run x86_64 binaries on aarch64 via qemu. This
    # package properly patches all the binaries so they have the right
    # x86_64 libs and linker cross-compiled so they'll just work if
    # you have binfmt_misc setup.
    playdate-sdk = prev.callPackage ./playdate-sdk.nix {};

    # Playdate requires gcc-arm-embedded v11. I haven't tested with later
    # versions but earlier versions do NOT work. At the time of gisting,
    # stable is 22.05 and only has gcc-arm-embedded v10. I overlay 
    # nixpkgs-unstable to get v11.
    gcc-arm-embedded = final.pkgs-unstable.gcc-arm-embedded-11;
  }
