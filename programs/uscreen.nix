{ inputs, pkgs, stdenv, ... }:

stdenv.mkDerivation rec {
  name = "uscreen";
  src = inputs.uscreen;

  nativeBuildInputs = with pkgs; [
    gcc
    rustc
  ];

  buildInputs = with pkgs; [
    android-tools
    displaylink
    ffmpeg
  ];

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/data

    cp $src/bin/uscreen $out/data/uscreen
    [ -f "$src/bin/uscreen-gui" ] && cp $src/data/uscreen-gui $out/data/uscreen-gui
    if [ -f "$src/bin/evdi_helper" ]; then
        cp "$src/bin/evdi_helper" "$out/data/evdi_helper"
        # The release helper finds libevdi next to itself ($ORIGIN rpath).
        [ -f "$src/bin/libevdi.so.1.15.0" ] && cp -P $src/bin/libevdi.so.1* $out/data/
    else
        cp "$PROJECT_DIR/host/evdi/evdi_helper" "$BIN_DIR/evdi_helper"
    fi

    ln -s $out/data/uscreen $out/bin/uscreen
    ln -s $out/data/uscreen-gui $out/bin/uscreen-gui
  '';
}
