function S2F = times(S2F1,S2F2)
% overloads |S2F1 .* S2F2|
%
% Syntax
%   S2F = S2F1 .* S2F2
%   S2F = a .* S2F1
%   S2F = S2F1 .* a
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
% multiplied. The product of two functions is then the MLS fit of the
% products of the values, not the product of the two fits.

[S2F,done] = valueOp(S2F1,S2F2,@times);
if ~done, S2F = times@S2Fun(S2F1,S2F2); end

end
