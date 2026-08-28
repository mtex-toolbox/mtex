function sP = properGroup(s)
% the proper rotation group of the Laue group of s

if isProper(s), sP = s; return; end

id = 0;
if s.id > 0
  pG = symmetry.pointGroups;
  id = pG(pG(s.id).LaueId).properId;
end

rot = s.rot;
if isLaue(s)
  rot = rot(~rot.i);        % drop the improper rotations
else
  rot.i = zeros(size(rot)); % make them all proper
end

sP = symmetry(id,rot);

end
