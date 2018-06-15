function sF = dthetasin(sF)
% first derivative in direction theta

s = size(sF);
sF = reshape(sF, []);

sF.fhat(1) = 0; % exclude some special cases
fhat = zeros((sF.bandwidth+2)^2, length(sF));
for m = 0:sF.bandwidth+1
  if 0 <= m-1
    fhat(m^2+1:(m+1)^2, :) = (m-1)*sqrt((m^2-(-m:m)'.^2)/((2*m-1)*(2*m+1))).*[zeros(1, length(sF)); sF.fhat((m-1)^2+1:m^2, :); zeros(1, length(sF))];
  end
  if m+1 <= sF.bandwidth
    fhat(m^2+1:(m+1)^2, :) = fhat(m^2+1:(m+1)^2, :)-(m+2)*sqrt(((m+1)^2-(-m:m)'.^2)/((2*m+1)*(2*m+3))).*sF.fhat((m+1)^2+2:(m+2)^2-1, :);
  end
end

sF = S2FunHarmonic(fhat);
sF = reshape(sF, s);

end
