function [a,b,c] = FCE(L,t)
% finite strain ellipsoid
%
% Syntax
%   [a,b,c] = FCE(L,t)
%   r = FCE(l,t)
%
% Input
%  L - 
%  t - time
%
% Output
%

Gamma = L.vorticity;

if nargout == 1

  % r = log(a/c)
  a = 2 * asinh(sinh(sqrt(1-Gamma.^2)) .* L.strainRate .* t ./ sqrt(1-Gamma.^2));

else

end


