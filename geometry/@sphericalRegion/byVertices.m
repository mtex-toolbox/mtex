function sR = byVertices(V,varargin)
% define a spherical region by its vertices
%
% Syntax
%   sR = sphericalRegion.byVertices(V)
%
% Input
%  V - @vector3d
%
% Output
%  sR - @sphericalRegion
%
% See also
% sphericalRegion/sphericalRegion

N = normalize(cross(V,V([2:end,1])));
alpha = zeros(size(N));

sR = sphericalRegion(N,alpha,varargin{:});

end
