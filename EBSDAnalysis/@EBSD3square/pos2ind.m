function [i,j,k] = pos2ind(ebsd,pos,y,z)
% convert x,y,z coordinates into indices of EBSD3square
%
% Syntax
%
%   ind = pos2ind(ebsd,pos)
%   ebsd(ind)
%
%   [i,j,k] = pos2ind(ebsd,x,y,z)
%   ebsd(i,j,k)
%
% Input
%  ebsd  - @EBSD3square
%  x,y,z - spatial coordinates
%  pos   - @vector3d
%
% Output
%  ind  - index to @EBSD3square
%  i,j,k  - indices to @EBSD3square
%

if nargin > 2, pos = vector3d(pos,y,z); end

i = 1 + round(dot(pos - ebsd.pos(1,1), ebsd.d1) / norm(ebsd.d1).^2);
j = 1 + round(dot(pos - ebsd.pos(1,1), ebsd.d2) / norm(ebsd.d2).^2);
k = 1 + round(dot(pos - ebsd.pos(1,1), ebsd.d3) / norm(ebsd.d3).^2);

if nargout <= 1, i = sub2ind(size(ebsd),i,j); end
