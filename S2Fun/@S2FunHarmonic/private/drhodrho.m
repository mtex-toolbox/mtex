function sF = drhodrho(sF)
% second derivative in direction rho

s = size(sF);
sF = reshape(sF, []);

fhat = zeros(size(sF.fhat));
for m = 0:sF.bandwidth
  fhat(m^2+1:(m+1)^2, :) = -((-m:m).^2)'.*sF.fhat(m^2+1:(m+1)^2, :);
end
sF = S2FunHarmonic(fhat);

sF = reshape(sF, s);

end
