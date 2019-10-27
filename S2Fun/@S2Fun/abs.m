function sF = abs(sF, varargin)
% absolute value of a function
% Syntax
%   sF = abs(sF)
%   sF = abs(sF, 'bandwidth', bandwidth)
%
% Input
%  sF - @S2Fun
%
% Output
%  sF - @S2FunHarmonic
%
% Options
%  bandwidth - minimal degree of the spherical harmonic
%

if check_option(varargin, 'bandwidth')
  sF = max(sF, -sF, 'bandwidth', get_option(varargin, 'bandwidth'));
else
  sF = max(sF, -sF);
end

end
