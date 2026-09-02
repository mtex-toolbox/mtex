function unitCell = regularPoly(s,d,rot)
% a regular polygon with s vertices, as the vertices of a unit cell
%
% Syntax
%   unitCell = regularPoly(4,[dx dy],0)   % the rectangle dx × dy
%   unitCell = regularPoly(6,d,0)         % the hexagon of width d
%
% Input
%  s   - number of vertices
%  d   - width, or [dx dy]
%  rot - rotation angle
%
% Output
%  unitCell - s × 2 vertices
%
% See also
% calcUnitCell EBSD/updateUnitCell

c = exp(1i*((pi/s:pi/(s/2):2*pi)+rot))./sqrt((s/2));
unitCell = [real(c(:)),imag(c(:))].*d;

end
