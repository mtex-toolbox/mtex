function [A,stencil,dxy] = latticeBasis(ebsd)
% lattice basis, neighbour stencil and step size of a gridded EBSD map
%
% Derives the 2D lattice from ebsd.unitCell, so it works for any EBSD - a plain
% @EBSD, a phase subset, or a gridified map - without relying on a stored grid.
% This is the "on the fly" grid generation: whatever points are present are
% described by the lattice geometry taken from the unit cell.
%
% Syntax
%   [A,stencil,dxy] = ebsd.latticeBasis
%
% Output
%  A       - 2 x 2 basis, columns a1,a2 (physical units)
%  stencil - k x 2 integer neighbour offsets (k = 4 square, 6 hex)
%  dxy     - representative cell size
%
% See also
% EBSD/gridIndex

% ebsd.unitCell is a @vector3d, so this dispatches to the standalone
% latticeBasis(vector3d) function, not back to this method.
[A,stencil,dxy] = latticeBasis(ebsd.unitCell);

end