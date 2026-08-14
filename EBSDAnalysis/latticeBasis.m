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

% The construction below is 2d - it reads the cell as (x,y). For a map that
% does not lie in the xy plane that projection is degenerate: a cell in the
% xz plane collapses onto a line and A comes out singular, e.g. [d 0; 0 0],
% which then propagates as a cryptic indexing error out of assignGridIndex.
% So rotate the cell into the xy plane first and return A in THAT frame -
% the map plane frame. The caller reaches the same frame through
% ebsd.rot2Plane, which is derived from the same normal (EBSD.N is
% perp(ebsd.unitCell)), so the two agree by construction.
N = perp(unitCell);
if ~isnull(angle(N,zvector,'antipodal'))
  unitCell = rotation.map(N,zvector) * unitCell;
end

V = [unitCell.x(:), unitCell.y(:)];
V = V - mean(V,1);                       % centre the cell on the origin
k = size(V,1);

% cell-to-cell translations = 2 x edge midpoints
mids  = 0.5 * (V + V([2:end 1],:));
trans = 2 * mids;                        % k x 2, one per shared edge

% Choose the basis from the DIRECTIONS of these translations, never from
% their position in the list.
%
% trans carries one translation per edge, so both its order and the signs of
% its entries follow the order in which the unit cell's corners happen to be
% written down - and that is not an invariant of the cell. squarify sorts the
% corners by angle before gridding, which on the importers' cells also
% reverses the winding: the same 50 x 50 square arrived counter-clockwise
% from EBSD.load and clockwise from gridify. Reading a1 off trans(1,:) turned
% that into A = [50 0; 0 50] for one and A = [-50 0; 0 50] for the other - a
% mirrored, left handed (i,j) frame for the same lattice - which propagated
% through assignGridIndex into the decomposition and changed the
% reconstruction: forsterite gave 2931 grains and a total boundary length of
% 2109862.588230 one way against 2936 and 2109862.726874 the other, from
% identical measurements.
%
% Every translation occurs as a +-pair, so take from each pair the
% representative pointing into the upper half plane (+x on the axis itself).
% That is fixed by the geometry of the cell alone.
tol  = 1e-12 * max(vecnorm(trans,2,2));
flip = trans(:,2) < -tol | (abs(trans(:,2)) <= tol & trans(:,1) < 0);
trans(flip,:) = -trans(flip,:);

if k == 4
  % square: a1 = translation with the smallest polar angle, a2 the one
  % orthogonal to it, oriented so that the frame stays right handed
  [~,i1] = min(atan2(trans(:,2),trans(:,1)));
  a1 = trans(i1,:);
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

% right handed, so that the (i,j) frame cannot mirror with the cell's winding
if a1(1)*a2(2) - a1(2)*a2(1) < 0, a2 = -a2; end

A   = [a1(:) a2(:)];                     % columns are a1, a2
dxy = mean(vecnorm(A,2,1));
