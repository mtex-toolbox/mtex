function c = centroid(grains, varargin)
% centroid of the grains
% 
% Syntax
%
%   c = grains.centroid
%
% Input
%  grains - @grain3d
%
% Output
%  c - @vector3d
%
% See also
% grain3d/fitEllipse
%

if isnumeric(grains.F)
  
  % vertices of all faces
  V = grains.boundary.allV(grains.F);
  
  isF = any(grains.I_GF,1);
  
  % signed volumes of the tetrahedrons with center (0,0,0)
  sgnVol = zeros(width(grains.I_GF),1);
  sgnVol(isF) = det(V);
 
  % centroid of the tetrahedrons
  c = vector3d.zeros(width(grains.I_GF),1);
  c(isF) = mean(V,2);

  c = grains.I_GF * (sgnVol .* c) ./ (grains.I_GF * sgnVol);

else

  

end


