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

% Invert the grid basis rather than project onto its two directions
% separately. Projecting - dot(.,d1)/|d1|^2 - inverts the basis only when d1
% and d2 are perpendicular. A rotation keeps them perpendicular, so that
% went unnoticed, but a shear does not: on a 0.35 sheared twins map it
% answered (5,8) for the cell at (3,7) and (32,47) for the one at (20,40),
% the error growing with the distance from pos(1,1).
d = x - ebsd.pos(1,1);
A = [ebsd.d1.x, ebsd.d2.x; ebsd.d1.y, ebsd.d2.y];
ij = A \ [d.x(:).'; d.y(:).'];

i = 1 + round(reshape(ij(1,:),size(d)));
j = 1 + round(reshape(ij(2,:),size(d)));

if nargout <= 1, i = sub2ind(size(ebsd),i,j); end
