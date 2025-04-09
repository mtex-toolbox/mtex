function [i,j] = pos2ind(ebsd,x,y,z)
% convert x,y,z coordinates into indices of ebsd
%
% Syntax
%
%   ind = pos2ind(ebsd,x,y)
%   ebsd(ind)
%
%   [i,j] = pos2ind(ebsd,x,y,z)
%   ebsd(i,j)
%
%   ind = pos2ind(ebsd,pos)
%
% Input
%  ebsd   - @EBSDsquare
%  x,y,z  - spatial coordinates
%  pos    - @vector3d
%
% Output
%  ind  - index to @EBSDsquare
%  i,j  - indices to @EBSDsquare
%

if nargin == 4
  x = vector3d(x,y,z);
elseif nargin == 3
  x = vector3d(x,y,0);
end

i = 1 + round(dot(x - ebsd.pos(1,1), ebsd.d1) / norm(ebsd.d1).^2);
j = 1 + round(dot(x - ebsd.pos(1,1), ebsd.d2) / norm(ebsd.d2).^2);

if nargout <= 1, i = sub2ind(size(ebsd),i,j); end
