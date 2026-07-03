function sP = properGroup(s)
% return the corresponding Laue group 

if ~isempty(s.properRef)

  sP = s.properRef;

% if it is already a Laue group there is nothing to do
elseif s.isProper
  
  sP = s; 
  s.properRef = s;
  
else

  sP = s.copy;

  % new id
  if s.id > 0
    pG = symmetry.pointGroups;
    sP.id = pG(pG(s.id).LaueId).properId;
  end

  % compute symmetry elements
  rot = s.rot;
  if s.isLaue
    rot = rot(~rot.i); % remove all improper rotations
  else
    rot.i = zeros(size(rot));   % make all rotations proper
  end
  sP.rot = rot;
  sP.LaueRef = s.Laue;
  sP.properRef = sP;
  s.properRef = sP;
 
end
