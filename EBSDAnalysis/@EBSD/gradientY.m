function gY = gradientY(ebsd,varargin)
% orientation gradient in Y direction in specimen coordinates
%
% Works on any @EBSD, including a rotated or sheared grid - see
% private/gradientDir for how the lattice basis is inverted.
%
% Syntax
%   gY = ebsd.gradientY
%
% Input
%  ebsd - @EBSD
%
% Output
%  gY - length(ebsd) x 1 orientation gradient along Y
%
% See also
% EBSD/gradient EBSD/curvature

gY = gradientDir(ebsd,vector3d.Y,varargin{:});

end
