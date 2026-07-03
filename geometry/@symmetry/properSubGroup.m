function sP = properSubGroup(s)
% return the corresponding Laue group 

% if it is already a proper group there is nothing to do
if s.isProper, sP = s; return; end

sP = s.copy;

% remove all improper rotations
sP.rot = s.rot(~s.rot.i);

% new id
if s.id > 0
  sP.id = symmetry.pointGroups(s.id).properId;
end
  