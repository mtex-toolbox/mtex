function f_hat = calcFourier(SO3F,varargin)
% compute harmonic coefficients of SO3Fun
%
% Syntax
%
%  f_hat = calcFourier(SO3F)
%
%  f_hat = calcFourier(SO3F,'bandwidth',L)
%
% Input
%  SO3F - @SO3FunCBF
%     L - maximum harmonic degree
%
% Output
%  f_hat - harmonic/Fouier/Wigner-D coefficients
%


L = get_option(varargin,'bandwidth',SO3F.bandwidth);

A = SO3F.psi.A;
A = A(1:min(L+1,length(A)));

% symmetrize
h = SO3F.CS * SO3F.h;
h = repmat(h,1,length(SO3F.SS.rot));
r = SO3F.SS * SO3F.r;
r = repmat(r,length(SO3F.CS.rot),1);

f_hat = zeros(deg2dim(length(A)),1);
for l = 0:min(L,length(A)-1)
  hat = SO3F.weights * 4*pi / (2*l+1)^(3/2) * A(l+1) *...
    conj(sphericalY(l,h)).' * sphericalY(l,r);
  
  f_hat(deg2dim(l)+1:deg2dim(l+1)) = ...
    hat(:) / length(SO3F.CS.rot) / length(SO3F.SS.rot);
  
end

if SO3F.antipodal 
  f_hat = SO3FunHarmonic(f_hat,'antipodal');
  f_hat = f_hat.fhat;
end

end
