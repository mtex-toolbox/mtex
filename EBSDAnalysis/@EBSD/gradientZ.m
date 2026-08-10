function gZ = gradientZ(ebsd,varargin)
% orientation gradient in Z direction in specimen coordinates
%
% Works on any @EBSD, including a rotated or sheared grid - see
% private/gradientDir for how the lattice basis is inverted.
%
% Syntax
%   gZ = ebsd.gradientZ
%
% Input
%  ebsd - @EBSD
%
% Output
%  gZ - length(ebsd) x 1 orientation gradient along Z
%
% See also
% EBSD/gradient EBSD/curvature

gZ = gradientDir(ebsd,vector3d.Z,varargin{:});

end
