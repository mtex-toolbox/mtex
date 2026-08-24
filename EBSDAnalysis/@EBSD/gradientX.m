function gX = gradientX(ebsd,varargin)
% orientation gradient in X direction in specimen coordinates
%
% Works on any @EBSD, including a rotated or sheared grid - see
% private/gradientDir for how the lattice basis is inverted.
%
% Syntax
%   gX = ebsd.gradientX
%
% Input
%  ebsd - @EBSD
%
% Output
%  gX - length(ebsd) × 1 orientation gradient along X
%
% See also
% EBSD/gradient EBSD/curvature

gX = gradientDir(ebsd,vector3d.X,varargin{:});

end
