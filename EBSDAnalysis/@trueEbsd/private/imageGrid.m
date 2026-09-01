function pos = imageGrid(mg)
% the pixel positions of a mapImage in IMAGE coordinates
%
% x is the column coordinate and y the row coordinate, both in length units.
% That is not mg.pos, which is in the frame the data lives in - on a map
% whose grid runs along anything but +x and +y the two differ by a rotation.
%
% This is what remapShifted needs. The shifts it is given come out of
% @pairShifts in image x and y, so the grid has to be in the same coordinates
% or a rotated layout silently disagrees with its own displacement field.
%
% Syntax
%
%   pos = imageGrid(mg)
%
% Input
%  mg - @mapImage
%
% Output
%  pos - r × c @vector3d, x along columns and y along rows
%
% See also
% trueEbsd/undistort remapShifted mapImage/pos

gL = mg.layout;

x0 = dot(mg.origin,gL.basis(2));
y0 = dot(mg.origin,gL.basis(1));

sz = gridSize(mg);
[i,j] = ndgrid(0:sz(1)-1, 0:sz(2)-1);

pos = vector3d(x0 + j*mg.dx, y0 + i*mg.dy, zeros(sz));

end
