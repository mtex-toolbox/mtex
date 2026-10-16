function SO3F = times(SO3F1,SO3F2)
% overloads |SO3F1 .* SO3F2|
%
% Syntax
%   SO3F = SO3F1 .* SO3F2
%   SO3F = a .* SO3F2
%   SO3F = SO3F1 .* a
%
% Input
%  SO3F1, SO3F2 - @SO3FunMLS
%  a - double
%
% Output
%  SO3F - @SO3FunMLS, @SO3FunHarmonic
%
% Description
% With a number, or with an SO3FunMLS on the same nodes, the node values
% are multiplied. The product of two functions is then the MLS fit of the
% products of the values, not the product of the two fits.

[SO3F,done] = valueOp(SO3F1,SO3F2,@times);
if done, return; end

SO3F = times@SO3Fun(SO3F1,SO3F2);
SO3F = SO3FunHarmonic(SO3F,'bandwidth', ...
  min(getMTEXpref('maxSO3Bandwidth'),SO3F1.bandwidth + SO3F2.bandwidth));

end
