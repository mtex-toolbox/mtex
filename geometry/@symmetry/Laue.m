function sL = Laue(s)
% return the corresponding Laue group 

% maybe we have alread computed the Laue group
if ~isempty(s.LaueRef)

  sL = s.LaueRef;

elseif s.isLaue % if it is already a Laue group then there is nothing to do
  
  sL = s;

else
  
  rot = s.rot;
  rot = [rot(:),rot(:)];
  rot.i = repmat([0,1],size(rot,1),1);

  if s.id > 0
    if isa(s,'crystalSymmetry')
      sL = crystalSymmetry('pointId',symmetry.pointGroups(s.id).LaueId,rot);
    else
      sL = specimenSymmetry('pointId',symmetry.pointGroups(s.id).LaueId,rot);
    end
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
