function sz = grainSize(grains)
% returns the number of measurments per grain


sz = sum(grains.I_DG,1);
sz = transpose(full(sz(sz>0)));