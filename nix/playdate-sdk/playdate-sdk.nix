{
  stdenv,
  lib,
  fetchurl,
  pkgsIntel,
}: let

  # Build inputs for `pdc`
  pdcInputs = with pkgsIntel; [
    stdenv.cc.cc.lib
    libpng
    zlib
  ];

  # Build inputs for the simulator (excluding those from pdc)
  pdsInputs = with pkgsIntel; [
    udev
    gtk3
    pango
    cairo
    gdk-pixbuf
    glib
    webkitgtk
    xorg.libX11
    stdenv.cc.cc.lib
    libxkbcommon
    wayland
    SDL2.dev
  ];

  # For native, if and when we support that:
  # "$(cat $NIX_CC/nix-support/dynamic-linker)"
  dynamicLinker = "${pkgsIntel.glibc}/lib/ld-linux-x86-64.so.2";
in
  stdenv.mkDerivation rec {
    pname = "playdate_sdk";
    version = "2.0.3";

    src = fetchurl {
      url = "https://download.panic.com/playdate_sdk/Linux/PlaydateSDK-${version}.tar.gz";
      sha256 = "sha256-FNzb3OjXGZpTTuR9+ox9KZD0sKlYfoA7jg48lZeQrpE=";
    };

    buildInputs = pdcInputs;

    dontFixup = true;

    installPhase = ''
      runHook preInstall

      # Get our new root
      root=$out/opt/playdate-sdk-${version}

      # Everything else
      mkdir -p $out/opt/playdate-sdk-${version}
      cp -r ./ $out/opt/playdate-sdk-${version}
      ln -s $root $out/opt/playdate-sdk

      # Setup dependencies and interpreter
      patchelf \
        --set-interpreter "${dynamicLinker}" \
        --set-rpath "${lib.makeLibraryPath pdcInputs}" \
        $root/bin/pdc
      patchelf \
        --set-interpreter "${dynamicLinker}" \
        $root/bin/pdutil
      patchelf \
        --set-interpreter "${dynamicLinker}" \
        --set-rpath "${lib.makeLibraryPath pdsInputs}"\
        $root/bin/PlaydateSimulator

      # Binaries
      mkdir -p $out/bin
      cp $root/bin/pdc $out/bin/pdc
      cp $root/bin/pdutil $out/bin/pdutil
      cp $root/bin/PlaydateSimulator $out/bin/PlaydateSimulator

      runHook postInstall
    '';
  }
