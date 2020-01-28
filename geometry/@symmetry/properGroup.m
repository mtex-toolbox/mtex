function sP = properGroup(s)
% return the corresponding Laue group 

if ~isempty(s.properRef)

  sP = s.properRef;

% if it is already a Laue group there is nothing to do
elseif s.isProper
  
  sP = s; 
  s.properRef = s; 
  
else

  % compute symmetry elements
  rot = s.rot;
  if s.isLaue
    rot = rot(~rot.i); % remove all improper rotations
  else
    rot.i = zeros(size(rot));   % make all rotations proper
  end

  % set up the new symmetry
  if s.id > 0
  
    pG = symmetry.pointGroups;
    id = pG(pG(s.id).LaueId).properId;
  
    if isa(s,'crystalSymmetry')
      sP = crystalSymmetry('pointId',id,rot);
    else
      sP = specimenSymmetry('pointId',id,rot);
    end
  
  else
    sP = crystalSymmetry(rot);
  end
  
  try %#ok<TRYNC>
    sP.axes = s.axes;       % coordinate system
    sP.mineral = s.mineral; % mineral name
    sP.color  = s.color;    % color used for EBSD / grain plotting
  end
  
  s.properRef = sP;
  
end
