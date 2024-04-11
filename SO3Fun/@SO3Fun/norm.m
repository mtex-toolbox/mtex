function t = norm(SO3F,varargin)
% Calculate the L2-norm also known as texture index of a SO3Fun, by using
%
% $$ t = \sqrt{\frac1{8\pi^2}\int_{SO(3)} |f( R ) |^2 dR},$$
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

% switch to harmonic representation
SO3F = SO3FunHarmonic(SO3F);

% compute the norm
t = norm(SO3F,varargin{:});

%fun = SO3FunHandle(@(ori) abs(SO3F.eval(ori)).^2,SO3F.CS, SO3F.SS);
%t = sqrt(mean(fun));
%t = sqrt(mean(abs(SO3F).^2));
    
end
