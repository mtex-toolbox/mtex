function sR = cleanUp(sR)

ind = sR.alpha < -1+eps;

sR.N(ind) = [];
sR.alpha(ind) = [];

[sR.N,ind] = unique(sR.N);
sR.alpha = sR.alpha(ind);