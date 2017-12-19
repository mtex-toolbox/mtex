function sF = drhodrho(sF)

fhat = zeros(size(sF.fhat));
for m = 0:sF.M
  fhat(m*(m+1)+(-m:m)+1) = -((-m:m).^2)'.*sF.fhat(m*(m+1)+(-m:m)+1);
end
sF = S2FunHarmonic(fhat);

end
