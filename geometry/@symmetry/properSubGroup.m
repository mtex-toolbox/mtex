function sP = properSubGroup(s)
% the subgroup of proper rotations of s

if isProper(s), sP = s; return; end

id = 0;
if s.id > 0, id = symmetry.pointGroups(s.id).properId; end

sP = symmetry(id,s.rot(~s.rot.i));

end
