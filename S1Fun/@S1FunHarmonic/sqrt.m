function sF = sqrt(sF, varargin)
% square root of a function
%
% Syntax
%   sF = sqrt(sF)
%   sF = sqrt(sF, 'bandwidth', bandwidth)
%
% Input
%  sF - @S1FunHarmonic
%
% Output
%  sF - @S1FunHarmonic
%
% Options
%  bandwidth
%

sF = S1FunHarmonic.quadrature(@(x) sqrt(sF.eval(x)),varargin{:});

end
