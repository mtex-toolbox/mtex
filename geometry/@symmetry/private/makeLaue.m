function sL = makeLaue(s)
% return the corresponding Laue group 

sL = s.copy;

% new id
if s.id > 0, sL.id = symmetry.pointGroups(s.id).LaueId; end

% double number of rotations
rot = s.rot;
rot = [rot(:),rot(:)];
rot.i = repmat([0,1],size(rot,1),1);
sL.rot = rot;

end
