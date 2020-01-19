function res = isLaue(s)
% check whether s is a Laue group

if ~isempty(s.LaueRef)

  res = s.LaueRef == s;
  
elseif s.id > 0
  
  res = s.id == symmetry.pointGroups(s.id).LaueId;
  
else
    
  res = any(s.rot(:) == rotation.inversion); 
  
end
