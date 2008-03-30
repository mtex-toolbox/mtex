function handles = pf2crystal( appdata, handles )

cs = getCS(appdata.pf);
ss = getSS(appdata.pf);
handles = s2crystal( handles ,cs ,ss );