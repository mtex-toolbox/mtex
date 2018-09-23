function Gamma = vorticity(L)
% vorticity Gamma

Gamma = L.rotationRate ./ L.strainRate;