function check_sphericalY(varargin)

L = get_option(varargin,'bandwidth',5);
S2G = S2Grid('equispaced','points',100);

[theta,rho] = polar(S2G);

for l = 1:L
  
  Y1 = sphericalY(l,theta,rho);
  Y2 = sphericalYNFFT(theta,rho,l);
 
  e(l) = norm(Y1(:)-Y2(:))./numel(Y1);
  
end

plot(e)