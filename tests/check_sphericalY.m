function check_sphericalY(varargin)

L = get_option(varargin,'bandwidth',5);
S2G = equispacedS2Grid('points',100);

[theta,rho] = polar(S2G);

for l = 1:L
  
  Y1 = sphericalY(l,S2G);
  Y2 = sphericalYNFFT(theta,rho,l);
 
  e(l) = norm(Y1(:)-Y2(:))./numel(Y1);
  
end

plot(e)
