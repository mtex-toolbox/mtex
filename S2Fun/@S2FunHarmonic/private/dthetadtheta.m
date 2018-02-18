function sF = dthetadtheta(sF)
% second derivative in direction theta

s = size(sF);
sF = reshape(sF, []);

sF.fhat(1) = 0; % exclude some special cases
fhat_theta = zeros((sF.bandwidth+2)^2, length(sF));
for m = 0:sF.bandwidth+1
  if 0 <= m-1
    fhat_theta(m^2+1:(m+1)^2, :) = (m-1)*sqrt((m^2-(-m:m)'.^2)/((2*m-1)*(2*m+1))).*[zeros(1, length(sF)); sF.fhat((m-1)^2+1:m^2, :); zeros(1, length(sF))];
  end
  if m+1 <= sF.bandwidth
    fhat_theta(m^2+1:(m+1)^2, :) = fhat_theta(m^2+1:(m+1)^2, :)-(m+2)*sqrt(((m+1)^2-(-m:m)'.^2)/((2*m+1)*(2*m+3))).*sF.fhat((m+1)^2+2:(m+2)^2-1, :);
  end
end

sF_theta = S2FunHarmonic(fhat_theta);


fhat_theta_theta = zeros((sF_theta.bandwidth+2)^2, length(sF));
for m = 0:sF_theta.bandwidth+1
  if 0 <= m-1
    fhat_theta_theta(m^2+1:(m+1)^2, :) = (m-1)*sqrt((m^2-(-m:m)'.^2)/((2*m-1)*(2*m+1))).*[zeros(1, length(sF)); sF_theta.fhat((m-1)^2+1:m^2, :); zeros(1, length(sF))];
  end
  if m+1 <= sF_theta.bandwidth
    fhat_theta_theta(m^2+1:(m+1)^2, :) = fhat_theta_theta(m^2+1:(m+1)^2, :)-(m+2)*sqrt(((m+1)^2-(-m:m)'.^2)/((2*m+1)*(2*m+3))).*sF_theta.fhat((m+1)^2+2:(m+2)^2-1, :);
  end
end

sF_theta_theta = S2FunHarmonic(fhat_theta_theta);


f = @(v) (sF_theta_theta.eval(v)-cos(v.theta).*sF_theta.eval(v))./max(sin(v.theta).^2, 0.1);
sF = S2FunHarmonic.quadrature(f, 'bandwidth', sF.bandwidth);
sF = reshape(sF, s);

end
