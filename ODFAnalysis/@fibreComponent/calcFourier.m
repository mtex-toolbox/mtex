function f_hat = calcFourier(component,L,varargin)
% called by ODF/calcFourier
  
A = component.psi.A;
A = A(1:min(L+1,length(A)));

% symmetrize
h = component.CS.properGroup * component.h;
h = repmat(h,1,numProper(component.SS));
r = component.SS.properGroup * component.r;
r = repmat(r,numProper(component.CS),1);

f_hat = zeros(deg2dim(length(A)),1);
for l = 0:min(L,length(A)-1)
  hat = component.weights * 4*pi / (2*l+1) * A(l+1) *...
    conj(sphericalY(l,h)).' * sphericalY(l,r);
  
  f_hat(deg2dim(l)+1:deg2dim(l+1)) = ...
    hat(:) / numProper(component.CS) / numProper(component.SS);
  
end

end
