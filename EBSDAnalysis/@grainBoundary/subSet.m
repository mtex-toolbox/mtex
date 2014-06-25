function gB = subSet(gB,ind)
% 
%
% Input
%  gB - @grainBoundary
%  ind    - 
%
% Ouput
%  grains - @grainBoundary
%

gB.grains.F = gB.grains.F(ind,:);
gB.grains.I_FDint = gB.grains.I_FDint(ind,:);
gB.grains.I_FDext = gB.grains.I_FDext(ind,:);
