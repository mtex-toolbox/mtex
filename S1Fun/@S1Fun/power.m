function sF = power(sF,a)
% overloads |sF.^2|
%
% Syntax
%   sF = sF.^2
%
% Input
%  sF - @S1Fun
%  a - double
%
% Output
%  sF - @S1Fun
%

if ~isnumeric(a)
  error('The exponent has to be numeric.')
end

sF = S1FunHandle(@(o) sF.eval(o).^reshape(a,[1 size(a)]));


end