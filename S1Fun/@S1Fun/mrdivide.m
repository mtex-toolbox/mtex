function sF = mrdivide(sF,s)
% overload the / operator, i.e. one can now write @S1Fun / 2  in order
% to scale an S1Fun.
%
% x = sF / s solves the system of linear equations x*s = sF for a S1Fun x.
%
% Syntax
%   sF = sF / 2
% 
% Input
%  sF - @S1Fun
%  s    - constant, vector
%
% Output
%  sF - @S1Fun
%
% See also
% S1Fun/plus S1Fun/mtimes

if ~isnumeric(s)
  error('Second argument has to be numeric. Use ./ instead.')
end

sF = times(sF,inv(s));

end


