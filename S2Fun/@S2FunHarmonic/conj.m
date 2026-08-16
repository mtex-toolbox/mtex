function sF = conj(sF)
% conjugate S2FunHarmonic


bw = sF.bandwidth;
for n=0:bw
  ind = n^2+1:(n+1)^2;
  ind2 = flip(ind);
  sF.fhat(ind,:) = sF.fhat(ind2,:);
end
sF.fhat = conj(sF.fhat);

end
