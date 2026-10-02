function kappa = curvature(ebsd,varargin)
% the curvature tensor of every voxel
%
% A volume measures the orientation gradient along all three axes of its
% voxels, so its curvature tensor is complete: the dyads of the gradients
% with the unit steps they are taken along.
%
% Syntax
%   kappa = curvature(ebsd)
%
% Input
%  ebsd - @EBSD3square
%
% Output
%  kappa - @curvatureTensor
%
% See also
% EBSD3square.calcGND EBSD.curvature

kappa = dyad(ebsd.gradientX,normalize(ebsd.d1)) + ...
  dyad(ebsd.gradientY,normalize(ebsd.d2)) + ...
  dyad(ebsd.gradientZ,normalize(ebsd.d3));

kappa = curvatureTensor(kappa,'unit',['1/' ebsd.scanUnit]);

end
