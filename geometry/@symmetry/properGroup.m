function s = properGroup(s)
% return the corresponding Laue group 

% if it is already a Laue group there is nothing to do
if s.isProper, return;end

if s.isLaue
  
  % remove all improper rotations
  s.rot = s.rot(~s.rot.i);
    
else
  
  % make all rotations proper
  s.rot.i = zeros(size(s.rot));
  
end

% set new symmetry id
try
  pG = symmetry.pointGroups;
  s.id = pG(pG(s.id).LaueId).properId;
catch
  s.id = 0;
end
