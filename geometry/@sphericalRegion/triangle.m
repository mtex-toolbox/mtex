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
% see also
% sphericalRegion_index

sR = sphericalRegion.byVertices([a,b,c],varargin{:});

end
