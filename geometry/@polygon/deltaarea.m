function delta = deltaarea(p)
% calculates an percentile area difference between hull-polygon an grain-polygon
%
%% Input
%  p - @grain / @polygon
%
%% Output
%  delta   - area difference
%

A = area(p);
AE = hullarea(p);

delta = ((AE-A)./A)*100;