function sF = drho(sF);

fhat = zeros(size(sF.fhat));
for m = 0:sF.bandwidth
  fhat(m*(m+1)+(-m:m)+1) = i*(-m:m)'.*sF.fhat(m*(m+1)+(-m:m)+1);
end
sF = S2FunHarmonic(fhat);

end
