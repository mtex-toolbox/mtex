function t = nodeType(gB)
% the number of grains meeting at each vertex, +10 on the outer hull
%
% Syntax
%   t = nodeType(gB)
%
% Input
%  gB - @grain3Boundary
%
% Output
%  t - list with one entry per vertex of gB.allV
%
% Description
% Follows the convention of DREAM.3D: 2 for a vertex inside a boundary
% face, 3 on a triple line, 4 at a quadruple point, 12, 13, 14 for the same
% on the outer hull of the measured volume, 11 for a hull vertex inside a
% single grain, 0 for a vertex no face uses. Voxel corners may join up to
% eight grains and are numbered accordingly.
%
% See also
% grain3Boundary/edges grain3d/smoothBoundary grain3d/reduceBoundary

t = full(sum(gB.I_VG,2));

isHull = false(length(gB.allV),1);
isHull(gB.F(any(gB.grainId == 0,2),:)) = true;
t(isHull) = t(isHull) + 10;

end
