function ids = sharedBoundaryV(grains)
% vertices used by both the outer and the inner grain boundary
%
% Syntax
%   ids = sharedBoundaryV(grains)
%
% Description
% boundary and innerBoundary are two separate grainBoundary objects over one
% shared vertex list, and each one derives its junctions from its own face
% list. A vertex where an inner boundary ends on the outer boundary therefore
% looks like a plain degree 2 vertex to either of them, and a coarsening step
% would happily dissolve it - leaving the other boundary hanging off a vertex
% that is no longer on the walk. Pass these ids as 'protect' to keep them.
%
% grain2d/smoothBoundary gets at the same set through I_VF, which costs an nV × nF
% sparse matrix product; marking the face list directly is O(nF).
%
% Input
%  grains - @grain2d
%
% Output
%  ids - vertex ids, as indices into grains.allV
%
% See also
% grain2d/simplifyBoundary grain2d/reduceBoundary grainBoundary/simplify

nV = size(grains.allV,1);

usedOuter = false(nV,1);
usedOuter(grains.boundary.F(:)) = true;

usedInner = false(nV,1);
usedInner(grains.innerBoundary.F(:)) = true;

ids = find(usedOuter & usedInner);
