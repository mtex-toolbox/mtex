function sS=transpose(sS)
% transpose list of slipSystem

sS.b = sS.b.';
sS.n = sS.n.';
sS.CRSS = sS.CRSS.';