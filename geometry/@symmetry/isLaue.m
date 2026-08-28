function out = isLaue(s)
% check whether s is a Laue group

if s.id > 0
  out = s.id == symmetry.pointGroups(s.id).LaueId;
else
  out = any(s.rot(:) == rotation.inversion);
end

end
