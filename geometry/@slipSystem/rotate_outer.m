function sS = rotate_outer(sS,ori)
% rotate slip system

sS.b = rotate_outer(sS.b,ori);
sS.n = rotate_outer(sS.n,ori);

sS.CRSS = repmat(sS.CRSS(:).',length(ori),1);

end