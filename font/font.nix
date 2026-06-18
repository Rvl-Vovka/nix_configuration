{ stdenvNoCC, lib }:
stdenvNoCC.mkDerivation {
  pname = "Handwrite";
  version = "1.0";
  src = ./Handwrite.ttf; 
  unpackPhase = "true";
  installPhase = ''
    mkdir -p $out/share/fonts/truetype
    cp $src $out/share/fonts/truetype/
  '';
  meta = with lib; {
    description = "A font that looks like my handwriting";
    platforms = platforms.all;
  };
}
