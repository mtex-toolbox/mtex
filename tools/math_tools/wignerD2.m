function D = wignerD2(l, g)
% spherical harmonics of degree l
%
% $$ D_n^{k,l}(R) = \int_{S^2} Y_n^k(\xi) \, \overline{Y_n^l(R\cdot\xi)} d{\xi} $$
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
% WignerD sphericalY Wigner_D

r = equispacedS2Grid('resolution',1.5*degree);

Y1 = sphericalY(l,r);
Y2 = sphericalY(l,g*r);

D = Y1.' * conj(Y2)./length(r)*pi*4;
