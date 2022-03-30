function sL = makeLaue(s)
% return the corresponding Laue group 

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

end
