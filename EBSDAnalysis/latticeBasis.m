function [A,stencil,dxy] = latticeBasis(unitCell)
% derive the lattice basis and neighbour stencil from a unit cell
%
% The unit cell is the list of corner vertices of one pixel (4 for a square
% grid, 6 for a hexagonal grid), as returned by ebsd.unitCell. The
% cell-to-cell translation vectors are twice the edge-midpoint vectors; from
% these we pick a 2D basis A = [a1 a2] such that
%
%     pos = [i j] * A' + origin
%
% and a neighbour stencil in (i,j) coordinates. The construction makes no
% assumption on the grid orientation, so it also works for rotated maps.
%
% Input
%  unitCell - @vector3d, 4 (square) or 6 (hex) corner vertices
%
% Output
%  A       - 2x2 basis, columns a1,a2 (physical units)
%  stencil - k x 2 integer neighbour offsets (k = 4 square, 6 hex)
%  dxy     - representative spacing = mean column norm of A
%
% NB the derived (i,j) indexing is PRIVATE to the decomposition and need not
% agree with the matrix layout of a gridified EBSDsquare/EBSDhex object.

V = [unitCell.x(:), unitCell.y(:)];
V = V - mean(V,1);                       % centre the cell on the origin
k = size(V,1);

% cell-to-cell translations = 2 x edge midpoints
mids  = 0.5 * (V + V([2:end 1],:));
trans = 2 * mids;                        % k x 2, one per shared edge

if k == 4
  % square: a1 = first translation, a2 = the one orthogonal to it
  a1 = trans(1,:);
  d  = abs(trans * a1') ./ (vecnorm(trans,2,2) * norm(a1) + eps);
  cand = find(d < 0.5);                  % ~orthogonal to a1
  a2 = trans(cand(1),:);
  stencil = [1 0; -1 0; 0 1; 0 -1];

elseif k == 6
  % hex: a1 = translation with smallest polar angle in [0,pi),
  %      a2 = translation at +60 deg from a1  -> uniform axial neighbourhood
  ang = mod(atan2(trans(:,2),trans(:,1)), pi);
  [~,i1] = min(ang);
  a1 = trans(i1,:);
  ang1 = mod(atan2(a1(2),a1(1)), 2*pi);
  at = mod(atan2(trans(:,2),trans(:,1)), 2*pi);
  [~,i2] = min(abs(mod(at - ang1, 2*pi) - pi/3));
  a2 = trans(i2,:);
  stencil = [1 0; -1 0; 0 1; 0 -1; 1 -1; -1 1];

else
  error('latticeBasis:unitCell','unit cell must have 4 or 6 corners');
end

A   = [a1(:) a2(:)];                     % columns are a1, a2
dxy = mean(vecnorm(A,2,1));
