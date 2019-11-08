function sR = triangle(a,b,c,varargin)
% define a spherical triangle by its vertices
%
% Syntax
%   sR = sphericalRegion.triangle(a,b,c)
%
% Input
%  a, b, c - @vector3d
%
% Output
%  sR - @sphericalRegion
%
% See also
% sphericalRegion/sphericalRegion

sR = sphericalRegion.byVertices([a,b,c],varargin{:});

end
