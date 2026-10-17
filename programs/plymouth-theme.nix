{ pkgs, stdenv, ... }:

stdenv.mkDerivation rec {
  name = "plymouth-theme";
  src = ../configs/themes/plymouth;

  installPhase = ''
    mkdir -p $out/share/plymouth/themes/abstract_ring
    cp * $out/share/plymouth/themes/abstract_ring

    sed -i "s/\/usr/$(echo $out | sed 's/\//\\\//g')/g" $out/share/plymouth/themes/abstract_ring/abstract_ring.plymouth
  '';
}
