function sS = subSet(sS,ind)
% subindex vector3d

sS.b = sS.b(ind);
sS.n = sS.n(ind);

sS.b = sS.b(:);
sS.n = sS.n(:);

end
