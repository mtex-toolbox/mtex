function sR = cleanUp(sR)

ind = sR.alpha < -1+eps;

sR.N(ind) = [];
sR.alpha(ind) = [];

[~,ind] = unique(sR.N);
ind =sort(ind);
sR.N = sR.N(ind);
sR.alpha = sR.alpha(ind);
