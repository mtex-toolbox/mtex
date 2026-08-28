function v = stripSym(v)
% this direction written without the claim on its symmetrically equivalent set
%
% A direction singled out of a family - the plane an orientation relationship
% is defined by, one Burgers vector out of the twelve, the marker a label is
% being written next to - names itself and not the set it came from, so it is
% written in the group-free sibling of its frame and prints (hkl) / [uvw]
% rather than {hkl} / <uvw>.
%
% The lattice survives, so the indices, the d-spacing and the coordinates all
% read back unchanged. <referenceFrame.fullSym.html |fullSym|> is the way
% back, which is how <orientation.map.html |orientation/map|> still knows the
% point group of the phase.
%
% Syntax
%   v = stripSym(v)
%
% Input
%  v - @vector3d
%
% Output
%  v - @vector3d
%
% See also
% referenceFrame/stripSym referenceFrame/fullSym Miller

if hasSymmetry(v), v.frame = stripSym(v.frame); end

end
