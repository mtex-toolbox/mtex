function sF = dtheta(sF)

sF.fhat(1) = 0; % exclude some special cases
fhat = zeros((sF.bandwidth+2)^2, 1);
for m = 0:sF.bandwidth+1
  if 0 <= m-1
    fhat(m^2+1:(m+1)^2) = (m-1)*sqrt((m^2-(-m:m)'.^2)/((2*m-1)*(2*m+1))).*[0; sF.fhat((m-1)^2+1:m^2); 0];
  end
  if m+1 <= sF.bandwidth
    fhat(m^2+1:(m+1)^2) = fhat(m^2+1:(m+1)^2)-(m+2)*sqrt(((m+1)^2-(-m:m)'.^2)/((2*m+1)*(2*m+3))).*sF.fhat((m+1)^2+2:(m+2)^2-1);
  end
end

sF = S2FunHarmonic(fhat);
f = @(v) sF.eval(v)./max(sin(v.theta), 0.01);
sF = S2FunHarmonic.quadrature(f, 'm', max(2*sF.bandwidth, 100));

end
