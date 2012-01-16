function sz = grainSize(grains)



sz = sum(grains.I_DG,1);
sz = transpose(full(sz(sz>0)));