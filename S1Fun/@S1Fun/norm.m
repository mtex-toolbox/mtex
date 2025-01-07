function t = norm(sF,varargin)
% Calculate the L2-norm, by using
%
% $$ t = \sqrt{\frac1{2\pi}\int_{0}^{2\pi} |f(x) |^2 dx}.$$
%
% Syntax
%   t = norm(sF)
% 
% Input
%  sF - @S1Fun 
%
% Output
%  t - double
%
% Options
%  resolution  - choose mesh width by calculation of mean
%

% switch to Fourier series representation
sF = S1FunHarmonic(sF);

% compute the norm
t = norm(sF,varargin{:});

end
