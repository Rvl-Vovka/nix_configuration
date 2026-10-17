{ inputs, pkgs, stdenv, ... }:

stdenv.mkDerivation rec {
  name = "plymouth-theme";
  src = ../configs/themes/plymouth;

  installPhase = ''
    mkdir -p $out/share/plymouth/themes/abstract-ring
    cp * $out/share/plymouth/themes/abstract-ring

    sed -i "s/usr/$out/g" $out/share/plymouth/themes/abstract-ring/abstract_ring.plymouth
  '';
}
