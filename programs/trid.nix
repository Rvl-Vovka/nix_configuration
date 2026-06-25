{ stdenv, unzip }@inputs:

stdenv.mkDerivation rec {
  name = "trid";
  src = inputs.trid;

  buildInputs = [ unzip ];
  unpackPhase = "unzip ${src}";

  installPhase = ''
    mkdir -p $out/bin
    cp ${name}/trid.py $out/bin/trid
    chmod 555 $out/bin/trid
  '';
}
