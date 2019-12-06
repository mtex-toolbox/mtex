function f_hat = calcFourier(SO3F,varargin)
% called by ODF/calcFourier
  
L = get_option(varargin,'bandwidth',SO3F.bandwidth);

A = SO3F.psi.A;
A = A(1:min(L+1,length(A)));

% symmetrize
h = SO3F.CS * SO3F.h;
h = repmat(h,1,length(SO3F.SS));
r = SO3F.SS * SO3F.r;
r = repmat(r,length(SO3F.CS),1);

f_hat = zeros(deg2dim(length(A)),1);
for l = 0:min(L,length(A)-1)
  hat = SO3F.weights * 4*pi / (2*l+1) * A(l+1) *...
    conj(sphericalY(l,h)).' * sphericalY(l,r);
  
  f_hat(deg2dim(l)+1:deg2dim(l+1)) = ...
    hat(:) / length(SO3F.CS) / length(SO3F.SS);
  
end

end
