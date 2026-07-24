function [ij,origin] = assignGridIndex(pos,A)
% robust integer (i,j) lattice index for each point, given a 2x2 basis
%
% Rounds each point's step from its immediate predecessor and accumulates,
% rather than rounding the (potentially large) offset from a single common
% origin in one shot: a smooth but non-affine distortion (e.g. a
% trapezoidal stage drift) can put a far-away point more than half a cell
% from any single global fit, flipping a one-shot round() to the wrong
% integer and colliding two points onto the same cell, while the step
% between two adjacent measurements never carries more than a tiny
% fraction of that drift and so always rounds correctly. This assumes pos
% arrives in the scan's raster order (row-major or column-major),
% preserved even through logical subsetting (masking only leaves gaps, it
% never reorders what remains).
%
% Falls back to a single global fit if the sequential route still produces
% index collisions (e.g. pos is not in scan order at all, such as after an
% explicit re-sort) - exact for a genuinely rigid grid regardless of point
% order.
%
% Input
%  pos - n x 2 spatial coordinates (map plane only, z is not considered)
%  A   - 2 x 2 lattice basis, columns are the grid step vectors
%
% Output
%  ij     - n x 2 integer lattice index, minimum at [0 0]
%  origin - 1 x 2 physical position corresponding to ij = [0 0]

[I,J] = stepwiseIndex(pos,A);
if hasIndexCollision(I,J)
  [I,J] = globalIndex(pos,A);
end

origin = pos(1,:) + [min(I), min(J)] * A.';
ij = [I - min(I), J - min(J)];

end

% =========================================================================
function [I,J] = stepwiseIndex(pos,A)
% (I,J) from rounding each point's step from its predecessor, accumulated

d = diff(pos,1,1);           % (n-1) x 2
dIJ = A \ d.';                % 2 x (n-1)
I = [0; cumsum(round(dIJ(1,:)).')];
J = [0; cumsum(round(dIJ(2,:)).')];
end

% =========================================================================
function [I,J] = globalIndex(pos,A)
% (I,J) from rounding each point's offset from a single common origin

IJ = A \ (pos - pos(1,:)).';
I = round(IJ(1,:)).';
J = round(IJ(2,:)).';
end

% =========================================================================
function tf = hasIndexCollision(I,J)
% true if two points were assigned the same (I,J) cell

key = (I - min(I)) + (max(I) - min(I) + 1) * (J - min(J));
tf = numel(unique(key)) < numel(I);
end
