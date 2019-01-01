function s = properGroup(s)
% return the corresponding Laue group 

% if it is already a Laue group there is nothing to do
if s.isProper, return;end

if s.isLaue
  
  % remove all improper rotations
  ind = s.i == 0;
  s.a = s.a(ind);
  s.b = s.b(ind);
  s.c = s.c(ind);
  s.d = s.d(ind);
  s.i = s.i(ind);
  
else
  
  % make all rotations proper
  s.i = zeros(size(s.i));
  
end

% set new symmetry id
try
  pG = symmetry.pointGroups;
  s.id = pG(pG(s.id).LaueId).properId;
catch
  s.id = 0;
end





