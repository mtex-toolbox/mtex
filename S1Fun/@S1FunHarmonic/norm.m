function n = norm(sF)
% Calculate the L2-norm of a S1FunHarmonic (Fourier series), by using 
% Parsevalls equality for the integral
%
% $$ n = \sqrt{\frac1{2\pi}\int_{\mathcal S_1} |f(x)|^2 dx}$$,
%
% with $vol(S_1) = \int_{S_1} 1 dx = 2\pi$. 
%
% Syntax
%   n = norm(sF)
% 
% Input
%  sF - @S1FunHarmonic
%
% Output
%  n - double


s = size(sF);
n = sqrt(sum(abs(sF.fhat).^2, 1));
n = reshape(n, s);

end