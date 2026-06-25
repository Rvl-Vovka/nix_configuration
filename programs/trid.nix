{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "trid";
  
  src = pkgs.fetchzip {
    url = "https://mark0.net/download/trid.zip";
  };

  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out/bin
    cp ${name}/trid.py $out/bin/trid
    chmod 555 $out/bin/trid
  '';
}
