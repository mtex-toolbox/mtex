function sF = diff(sF, varargin)
% derivative of a periodic function
%
% Syntax
%   sF = diff(sF)
%
% Input
%  sF - @S1FunHarmonic
%
% Output
%  sF   - @S1FunHarmonic
%

bw = sF.bandwidth;
omega = (-bw:bw)*1i;

sF.fhat = sF.fhat .* omega.';

end