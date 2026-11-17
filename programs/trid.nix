{ inputs, pkgs, stdenv, ... }:

stdenv.mkDerivation rec {
  name = "trid";
  src = inputs.trid;
  triddefs = inputs.triddefs;

  buildInputs = with pkgs; [
    python3
  ];

  installPhase = ''
    mkdir -p $out/{bin,data}

    cp $src/trid.py $out/data/trid.py
    cp $triddefs/triddefs.trd $out/data/triddefs.trd

    # without this patch trid rejects cache because it thinks that the cache is older than definitions even though dates are equal and all dates in nix store are eqaul
    sed -i 's/if\ os\.path\.getmtime(cachefilename)\ >\ os\.path\.getmtime(filename):/if\ os\.path\.getmtime(cachefilename)\ >=\ os\.path\.getmtime(filename):/' $out/data/trid.py

    # there is no way to generate triddefs cache (or I was not able to find it) except for force trid to analyze some file; cache can't be generated after installtion (read-only filesystem)
    python $out/data/trid.py $out/data/trid.py

    # files in bin folder are in system PATH, data folder is needed to store definitions and cache so they don't appear in my system PATH
    ln -s $out/data/trid.py $out/bin/trid

    chmod 555 $out/data/trid.py
  '';
}
