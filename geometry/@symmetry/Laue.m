function s = Laue(s)
% return the corresponding Laue group 

% if it is already a Laue group there is nothing to do
if s.isLaue, return;end

s.a = [s.a(:),s.a(:)];
s.b = [s.b(:),s.b(:)];
s.c = [s.c(:),s.c(:)];
s.d = [s.d(:),s.d(:)];
s.i = repmat([0,1],size(s.a,1),1);

if s.id > 0
  s.id = symmetry.pointGroups(s.id).LaueId;
end





