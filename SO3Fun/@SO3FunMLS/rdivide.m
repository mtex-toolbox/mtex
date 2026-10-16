function SO3F = rdivide(SO3F1,SO3F2)
% overloads ./
%
% Syntax
%   SO3F = SO3F1 ./ SO3F2
%   SO3F = SO3F1 ./ a
%   SO3F = a ./ SO3F2
%
% Input
%  SO3F1, SO3F2 - @SO3FunMLS
%  a - double
%
% Output
%  SO3F - @SO3FunMLS, @SO3Fun
%
% Description
% With a number, or with an SO3FunMLS on the same nodes, the node values
% are divided. The quotient of two functions is then the MLS fit of the
% quotients of the values, not the quotient of the two fits.

[SO3F,done] = valueOp(SO3F1,SO3F2,@rdivide);
if ~done
  SO3F = rdivide@SO3Fun(SO3F1,SO3F2);
elseif any(isinf(SO3F.values(:)))
  warning('After division, the resulting function has Inf values.');
end

end
