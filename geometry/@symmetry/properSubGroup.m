function s = properSubGroup(s)
% return the corresponding Laue group 

% if it is already a Laue group there is nothing to do
if s.isProper, return;end

% remove all improper rotations
s.rot = s.rot(~s.rot.i);

% set new symmetry id
s.id = symmetry.pointGroups(s.id).properId;
