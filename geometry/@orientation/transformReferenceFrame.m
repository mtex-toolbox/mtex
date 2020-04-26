function ori = transformReferenceFrame(ori,cs1,cs2)
% change reference frame of an orientation
%
% Orientations are always described with respect to a cartesian reference
% frame x, y, z aligned in a fixed way with the crystal coordiante system
% a, b, c. Typical alignments are x||a and z||c* or x||a* and z||c. This
% function allows to change the aligment of the reference frame while NOT
% changing the orientation.
%
% Syntax
%   ori = ori.transformReferenceFrame(cs)
%   mori = mori.transformReferenceFrame(cs1,cs2)
%
% Input
%  ori - @orientation
%  mori - misorientation
%  cs, cs1, cs2 - @crystalSymmetry
%

% only applicable for crystal symmetry
if ~isa(cs1,'crystalSymmetry')
  warning('Symmetry missmatch!')
  ori.CS = cs1;
  return
end

% basis transformation into reference frame
M = transformationMatrix(ori.CS,cs1);

% check symmetries are compatible
if ori.CS.id ~= cs1.id || norm(eye(3)-M*M.')>0.01 || ...
    all(norm(ori.CS.axes - cs1.axes)./norm(cs1.axes)<10^-2) || ...
    (~isempty(ori.CS.mineral) && ~isempty(cs1.mineral) && ~strcmpi(ori.CS.mineral,cs1.mineral))
  warning('Symmetry missmatch! The following crystal frames seem to be different\n\n  %s\n  %s \n',char(ori.CS,'verbose'),char(cs1,'verbose'));
end

if det(M)>10*eps
  rot = rotation(ori) * rotation('matrix',M^-1);

  ori = orientation(rot,cs1,ori.SS);
end

% do the same for the second symmetry
if nargin == 3, ori = inv(transformReferenceFrame(inv(ori),cs2)); end

% this is some testing code
% cs1 = crystalSymmetry('triclinic',[1 2 3],[70 80 120]*degree,'Z||a*')
% cs2 = crystalSymmetry('triclinic',[1 2 3],[70 80 120]*degree,'Z||b','X||a*')
% o = orientation.byEuler(30*degree,50*degree,120*degree,cs1)
% o * Miller(1,0,0,cs1)
% o2 = transformReferenceFrame(o,cs2)
% o2 * Miller(1,0,0,cs2)
