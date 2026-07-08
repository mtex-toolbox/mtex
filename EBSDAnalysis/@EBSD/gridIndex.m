function [ij,A,stencil,dxy] = gridIndex(ebsd)
% integer (i,j) lattice index of every EBSD pixel
%
% Computes, for each measurement, its position on the lattice defined by
% ebsd.unitCell. Works for any EBSD without a stored grid (on the fly grid
% generation): scattered points, phase subsets and gridified maps alike are
% snapped to the nearest lattice node.
%
% Syntax
%   ij = ebsd.gridIndex
%   [ij,A,stencil,dxy] = ebsd.gridIndex
%
% Output
%  ij      - nEbsd x 2 integer lattice indices [i j]
%  A       - 2 x 2 lattice basis (see latticeBasis)
%  stencil - neighbour stencil
%  dxy     - cell size
%
% Note: the indices are RELATIVE to this data's own extent (origin =
% min(pos)). A phase subset therefore gets its own origin; do not compare
% indices across different subsets expecting a common frame.
%
% See also
% EBSD/latticeBasis

[A,stencil,dxy] = latticeBasis(ebsd.unitCell);

pos = [ebsd.pos.x(:), ebsd.pos.y(:)];
ij  = round((pos - min(pos,[],1)) / A.');   % nEbsd x 2

end