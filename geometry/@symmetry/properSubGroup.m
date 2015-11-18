function s = properSubGroup(s)
% return the corresponding Laue group 

% if it is already a Laue group there is nothing to do
if s.isProper, return;end

% remove all improper rotations
ind = s.i == 0;
s.a = s.a(ind);
s.b = s.b(ind);
s.c = s.c(ind);
s.d = s.d(ind);
s.i = s.i(ind);
  
% set new symmetry id
s.id = symmetry.pointGroups(s.id).properId;
