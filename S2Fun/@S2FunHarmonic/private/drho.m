function sF = drho(sF)
% first derivative in direction rho

s = size(sF);
sF = reshape(sF, []);

fhat = zeros(size(sF.fhat));
for m = 0:sF.bandwidth
  fhat(m*(m+1)+(-m:m)+1, :) = 1i*(-m:m)'.*sF.fhat(m*(m+1)+(-m:m)+1, :);
end
sF = S2FunHarmonic(fhat);

sF = reshape(sF, s);

end
