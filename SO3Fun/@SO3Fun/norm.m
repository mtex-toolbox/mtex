function t = norm(SO3F)
% Calculate the L2-norm also known as texture index of a SO3Fun, by using
%
% $$ t = \sqrt{\frac1{8\pi^2}\int_{SO(3)} |f(R)|^2 dR}$$,
%
% where $vol(SO(3)) = \int_{SO(3)} 1 dR = 8\pi^2$.
%
% Syntax
%   t = norm(SO3F)
% 
% Input
%  SO3F - @SO3Fun 
%
% Output
%  t - double
%
% Options
%  resolution  - choose mesh width by calculation of mean
%

t = sqrt(mean(abs(SO3F).^2));
    
end
