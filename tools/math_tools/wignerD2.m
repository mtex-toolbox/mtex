function D = wignerD2(l, g)
% spherical harmonics of degree l
%
% Input
%  l     - degree
%  theta - azimuth angle
%  rho   - polar
%
% Output
%  Y - (2l+1) x numel(theta,rho) matrix of function values
%
% See also
% wignerD sphericalY

r = equispacedS2Grid('resolution',1.5*degree);

Y1 = sphericalY(l,r);
Y2 = sphericalY(l,g*r);

D = Y1' * Y2./length(r)*pi*4;
