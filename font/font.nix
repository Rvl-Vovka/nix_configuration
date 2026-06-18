{ pkgs }:
pkgs.stdenvNoCC.mkDerivation {
  pname = "Handwrite";
  version = "1.0";
  src = ./Handwrite.ttf; 
  installPhase = ''
    mkdir -p $out/share/fonts/truetype
    cp $src $out/share/fonts/truetype/
  '';
  meta = {
    description = "A font that looks like my handwriting";
    platforms = pkgs.lib.platforms.all;
  };
}
