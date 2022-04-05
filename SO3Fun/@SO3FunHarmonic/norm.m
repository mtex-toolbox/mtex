function n = norm(SO3F)
% Calculate the L2-norm also known as texture index of a SO3FunHarmonic, by
% using Parsevalls equality for the integral
%
% $$ t = \sqrt{\int_{SO(3)} |f(R)|^2 dR}$$,
%
% with $vol(SO(3)) = \int_{SO(3)} 1 dR = 8\pi^2$.
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

% norm of Wigner-D functions is 1

s = size(SO3F);
SO3F = SO3F.subSet(':');
n = sqrt(sum(abs(SO3F.fhat).^2, 1));
n = reshape(n, s);

end
