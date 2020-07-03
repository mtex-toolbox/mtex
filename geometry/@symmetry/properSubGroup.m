function sP = properSubGroup(s)
% return the corresponding Laue group 

% if it is already a Laue group there is nothing to do
if s.isProper, sP = s; return; end

% remove all improper rotations
rot = s.rot(~s.rot.i);

if s.id > 0
  id = symmetry.pointGroups(s.id).properId;
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
  