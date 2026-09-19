function [w,psi] = kernelWeights(bw)
% the restricted distance kernel, and the weights its discrepancy puts on
% the Wigner coefficients - degree 0 dropped, it does not contribute

psi = SO3RestrictedDistanceKernel(bw+1);

w = zeros(deg2dim(bw+1),1);
for l = 1:bw
  w(deg2dim(l)+1:deg2dim(l+1)) = sqrt( 8*pi^2 * psi.A(l+1)/(2*l+1) );
end

end
