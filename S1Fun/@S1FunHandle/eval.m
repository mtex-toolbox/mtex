function f = eval(sF,omega,varargin)
% evaluate a S1FunHandle
% 
% Syntax
%   f = eval(sF,omega)
%
% Input
%   sF - @S1FunHandle
%   omega - double (evaluation nodes)
%
% Output
%   f - double
%
% See also
% S1FunHarmonic/eval


f = sF.fun(omega);

if isalmostreal(f)
  f = real(f);
end

end