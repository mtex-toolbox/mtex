function handles = ebsd2crystal( appdata, handles )

[cs, ss] = getSym(appdata.ebsd);

handles = s2crystal( handles ,cs ,ss );