function sF = cat(d, sF1, sF2)

[bandwidth, I] = max([sF1.bandwidth, sF2.bandwidth]);
if I == 2
  tmp = sF1;
  sF1 = sF2;
  sF2 = tmp;
end % sF1 has bigger bandwidth

if sF1.bandwidth ~= sF2.bandwidth
  s = size(sF2);
  sF2.fhat = [sF2.fhat; zeros([size(sF1.fhat, 1)-size(sF2.fhat, 1), s])];
end

sF = S2FunHarmonic(cat(d+1, sF1.fhat, sF2.fhat));

end
