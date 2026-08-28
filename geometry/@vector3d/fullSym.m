function v = fullSym(v)
% this direction written as the whole symmetrically equivalent set it belongs to
%
% The way back from <vector3d.stripSym.html |stripSym|>, for a caller that
% needs what the group provides - symmetrise, a fit taken over the orbit, or
% the lattice type, which follows from the group and is triclinic without one.
%
% Syntax
%   v = fullSym(v)
%
% Input
%  v - @vector3d
%
% Output
%  v - @vector3d
%
% See also
% vector3d/stripSym referenceFrame/fullSym

if hasSymmetry(v) || isCrystalDirection(v), v.frame = fullSym(v.frame); end

end
