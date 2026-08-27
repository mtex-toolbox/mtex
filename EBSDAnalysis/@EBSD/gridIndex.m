function [ij,A,stencil,dxy] = gridIndex(ebsd)
% integer (i,j) lattice index of every EBSD pixel
%
% Computes, for each measurement, its position on the lattice defined by
% ebsd.unitCell. Works for any EBSD without a stored grid (on the fly grid
% generation): scattered points, phase subsets and gridified maps alike are
% snapped to the nearest lattice node.
%
% Thin wrapper around ebsd.lattice, kept for backward compatibility with
% existing callers (EBSD/KAM, EBSD/curvature).
%
% Syntax
%   ij = ebsd.gridIndex
%   [ij,A,stencil,dxy] = ebsd.gridIndex
%
% Output
%  ij      - nEbsd × 2 integer lattice indices [i j]
%  A       - 2 × 2 lattice basis (see latticeBasis)
%  stencil - neighbour stencil
%  dxy     - cell size
%
% Note: the indices are RELATIVE to this data's own extent. A phase subset
% therefore gets its own origin; do not compare indices across different
% subsets expecting a common frame.
%
% See also
% EBSD/lattice EBSD/latticeBasis

g = ebsd.lattice;
ij = g.ij; A = g.A; stencil = g.stencil; dxy = g.dxy;

end
