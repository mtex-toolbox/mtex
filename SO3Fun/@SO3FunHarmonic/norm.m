function n = norm(SO3F)
% Calculate the L2-norm also known as texture index of a SO3FunHarmonic, by
% using Parsevalls equality for the integral
%
% $$ t = \sqrt{\frac1{8\pi^2}\int_{SO(3)} |f(R)|^2 dR}$$,
%
% with $vol(SO(3)) = \int_{SO(3)} 1 dR = 8\pi^2$. 
% The Wigner-D functions (one Wigner-coefficient is 1 and all others are 0) 
% are L2-normalized.
%
% Syntax
%   t = norm(SO3F)
% 
% Input
%  SO3F - @SO3FunHarmonic
%
% Output
%  t - double
%
% Options
%  resolution  - choose mesh width by calculation of mean
%

s = size(SO3F);
SO3F = SO3F.subSet(':');
n = sqrt(sum(abs(SO3F.fhat).^2, 1));
n = reshape(n, s);

end
