function out = isCrystalDirection(v)
% whether a direction is given in crystal coordinates
%
% A direction expressed in a <crystalFrame.crystalFrame.html |crystalFrame|>
% has Miller indices and a d-spacing; one in a specimen frame, or in none at
% all, has neither. This asks that question of the object rather than of its
% class, which is what makes it survive @Miller becoming an ordinary framed
% @vector3d (ADR 0008 rule 6).
%
% It is the replacement for |isa(x,'Miller')|, which goes silently false when
% the class does.
%
% Syntax
%   out = isCrystalDirection(v)
%
% Input
%  v - anything
%
% Output
%  out - logical
%
% Example
%
%   cs = crystalSymmetry('m-3m',[4.05 4.05 4.05]);
%   isCrystalDirection(Miller(1,0,0,cs))
%   isCrystalDirection(xvector)
%
% See also
% crystalFrame vector3d/frame Miller

out = isa(v,'vector3d') && isa(v.frame,'crystalFrame');

end
