function sS=transpose(sS)
% transpose list of slipSystem

sS.b = sS.b.';
sS.l = sS.l.';
sS.u = sS.u.';