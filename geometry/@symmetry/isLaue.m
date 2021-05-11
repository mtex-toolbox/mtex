function out = isLaue(s)
% check whether s is a Laue group

if ~isempty(s.LaueRef)
  
  out = s.LaueRef == s;
  
else
  
  if s.id > 0
    out = s.id == symmetry.pointGroups(s.id).LaueId;
  else
    out = any(s.rot(:) == rotation.inversion);
  end
  
  % store Laue group to speed up further checks
  if out
    s.LaueRef = s;
  else
    s.LaueRef = makeLaue(s);
  end
  
end
