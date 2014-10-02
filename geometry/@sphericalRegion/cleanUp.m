function sR = cleanUp(sR)

ind = sR.alpha < -1+eps;

sR.N(ind) = [];
sR.alpha(ind) = [];
