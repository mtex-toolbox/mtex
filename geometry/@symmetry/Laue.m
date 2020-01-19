function sL = Laue(s)
% return the corresponding Laue group 

% if it is already a Laue group then there is nothing to do
if ~isempty(s.LaueRef)

  sL = s.LaueRef;

elseif s.isLaue
  
  sL = s;

else
  
  rot = [s.rot(:),s.rot(:)];
  rot.i = repmat([0,1],size(s.rot,1),1);

  if s.id > 0
    sL = crystalSymmetry('pointId',symmetry.pointGroups(s.id).LaueId);
    sL.rot = rot;
  else
    sL = crystalSymmetry(rot);
  end
  
  sL.axes = s.axes;       % coordinate system
  sL.mineral = s.mineral; % mineral name
  sL.color  = s.color;    % color used for EBSD / grain plotting
    
end
