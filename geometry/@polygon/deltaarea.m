function delta = deltaarea(grains)
% calculates an percentile area difference between hull-polygon an grain-polygon
%
%% Input
%  grains - @grain
%
%% Output
%  delta   - area difference
%

A = area(grains);
AE = hullarea(grains);

delta = ((AE-A)./A)*100;