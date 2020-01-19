function sL = Laue(s)
% return the corresponding Laue group 

% if it is already a Laue group then there is nothing to do
if ~isempty(s.LaueRef)

  sL = s.LaueRef;

elseif s.isLaue
  
  sL = s;

else
  
  rot = s.rot;
  rot = [rot(:),rot(:)];
  rot.i = repmat([0,1],size(rot,1),1);

  if s.id > 0
    if isa(s,'crystalSymmetry')
      sL = crystalSymmetry('pointId',symmetry.pointGroups(s.id).LaueId);
    else
      sL = specimenSymmetry('pointId',symmetry.pointGroups(s.id).LaueId);
    end
    sL.rot = rot;
  else
    sL = crystalSymmetry(rot);
  end
  
  try %#ok<TRYNC>
    sL.axes = s.axes;       % coordinate system
    sL.mineral = s.mineral; % mineral name
    sL.color  = s.color;    % color used for EBSD / grain plotting
  end
  
  % save for the future
  s.LaueRef = sL;
end
