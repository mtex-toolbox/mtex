function sL = Laue(s)
% the smallest Laue group containing s

if isLaue(s), sL = s; return; end

id = 0;
if s.id > 0, id = symmetry.pointGroups(s.id).LaueId; end

% every element once proper and once improper
rot = s.rot;
rot = [rot(:),rot(:)];
rot.i = repmat([0,1],size(rot,1),1);

sL = symmetry(id,rot);

end
