function sS = rotate(sS,ori)
% rotate slip system

sS.b = rotate(sS.b,ori);
sS.n = rotate(sS.n,ori);

end