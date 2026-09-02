function [w,psi] = kernelWeights(bw,antipodal)
% the restricted distance kernel, and the weights its discrepancy puts on
% the harmonic coefficients - degree 0 dropped, it does not contribute

psi = S2RestrictedDistanceKernel(bw+1);

% for antipodal functions the odd degrees vanish anyway
if antipodal, psi.A(2:2:end) = 0; end

w = zeros((bw+1)^2,1);
for l = 1:bw
  w(l^2+1:(l+1)^2) = sqrt( 4*pi * psi.A(l+1)/(2*l+1) );
end

end
