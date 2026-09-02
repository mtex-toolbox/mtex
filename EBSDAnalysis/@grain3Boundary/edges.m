function [E,F2E] = edges(gB)
% the edges of a triangulated boundary
%
% Syntax
%   [E,F2E] = edges(gB)
%
% Input
%  gB - @grain3Boundary with triangular faces
%
% Output
%  E   - nE x 2 list of vertex pairs, each edge once, smaller id first
%  F2E - nF x 3 ids into E of the edges of each face, in the order 12, 23, 31
%
% Description
% An edge with three or more faces lies on a triple line, which is where
% <grain3Boundary.nodeType.html |nodeType|> and
% <grain3d.smoothBoundary.html |smoothBoundary|> take it from.
%
% See also
% grain3Boundary/nodeType grain3d/smoothBoundary grain3d/refineBoundary

assert(isnumeric(gB.F) && size(gB.F,2) == 3,'edges needs triangular faces, see grain3d/triangulate')

[E,~,F2E] = unique(sort([gB.F(:,[1 2]); gB.F(:,[2 3]); gB.F(:,[3 1])],2),'rows');
F2E = reshape(F2E,[],3);

end
