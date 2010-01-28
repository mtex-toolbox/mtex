function rot = symmetrise(rot,CS,SS)	
% all crystallographically equivalent orientations


rot.quaternion = symmetrise(rot.quaternion,CS,SS);
rot.i = repmat(rot.i(:).',length(SS) * length(CS),1);
