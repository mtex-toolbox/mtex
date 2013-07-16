function f_hat = doFourier(odf,L,varargin)
% called by ODF/calcFourier
  
A = getA(odf.psi);
A = A(1:min(L+1,length(A)));

% symmetrize
h = odf.CS * vector3d(odf.h);
h = repmat(h,1,length(odf.SS));
r = odf.SS * odf.r;
r = repmat(r,length(odf.CS),1);
[theta_h,rho_h] = polar(h(:));
[theta_r,rho_r] = polar(r(:));

f_hat = zeros(deg2dim(length(A)),1);
for l = 0:min(L,length(A)-1)
  hat = odf.c * 4*pi / (2*l+1) * A(l+1) *...
    sphericalY(l,theta_h,rho_h).' * conj(sphericalY(l,theta_r,rho_r));
  
  hat = hat';
  
  f_hat(deg2dim(l)+1:deg2dim(l+1)) = ...
    hat(:) / length(odf.CS) / length(odf.SS);
  
end

end
