function [ghat,k,l] = foldedWignerTrafo(fhat,N,isReal,rZ)
% Fourier coefficients of a Wigner series on the lattice of the Z-axis symmetries
%
% Description
% Transforms the Wigner coefficients fhat up to degree N into the Fourier
% coefficients ghat(k,j,l) of the trivariate Fourier series in the Euler
% angles, keeping only the orders k and l that are multiples of the Z-axis
% symmetries rZ = [right,left]. Dimension 1 runs over k = k(1):rZ(1):k(end),
% dimension 2 over j = -N-1:N and dimension 3 over l, which is l >= 0 (from
% -1 if N is even and rZ(2) = 1) if the function is real valued, all zero
% padded to even length. The plane l = 0 of a real valued function is halved.
%
% Input
%  fhat   - Wigner coefficients of one function, up to degree N or more
%  N      - bandwidth
%  isReal - use the half lattice l >= 0 of a real valued function
%  rZ     - multiplicities of the Z-axis symmetries
%
% Output
%  ghat - Fourier coefficients
%  k, l - orders along dimension 1 and 3
%

ghat = wignerTrafomex(N,double(fhat),2^0+isReal*2^2+2^4+2^5,[1,rZ(1),1,rZ(2)]);

k = -rZ(1)*floor((N+1)/rZ(1)) + (0:size(ghat,1)-1)'*rZ(1);
if isReal
  l0 = -(rZ(2)==1 && mod(N,2)==0);
else
  l0 = -rZ(2)*floor((N+1)/rZ(2));
end
l = reshape(l0 + (0:size(ghat,3)-1)*rZ(2),1,1,[]);

end
