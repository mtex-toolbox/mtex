function sF = mrdivide(sF,s)
% overload the / operator, i.e. one can now write @S2Fun / 2  in order
% to scale an S2Fun.
%
% Syntax
%   sF = sF / 2
% 
% Input
%  sF - @S2Fun
%  s  - constant, vector
%
% Output
%  sF - @S2Fun
%

if ~isnumeric(s)
  error('Second argument has to be numeric. Use ./ instead.')
end

sF = times(sF,inv(s));

end