function sS = rotate(sS,ori)
% rotate slip system

sS.b = rotate(sS.b,ori);
sS.n = rotate(sS.n,ori);

if isscalar(sS.CRSS)
  sS.CRSS = repmat(sS.CRSS,size(sS.b));
end

end