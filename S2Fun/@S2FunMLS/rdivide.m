function S2F = rdivide(S2F1,S2F2)
% overloads ./
%
% Syntax
%   S2F = S2F1 ./ S2F2
%   S2F = S2F1 ./ a
%   S2F = a ./ S2F2
%
% Input
%  S2F1, S2F2 - @S2FunMLS
%  a - double
%
% Output
%  S2F - @S2FunMLS, @S2Fun
%
% Description
% With a number, or with an S2FunMLS on the same nodes, the node values are
% divided. The quotient of two functions is then the MLS fit of the
% quotients of the values, not the quotient of the two fits.

[S2F,done] = valueOp(S2F1,S2F2,@rdivide);
if ~done
  S2F = rdivide@S2Fun(S2F1,S2F2);
elseif any(isinf(S2F.values(:)))
  warning('After division, the resulting function has Inf values.');
end

end
