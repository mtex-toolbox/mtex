function SO3F = plus(SO3F1,SO3F2)
% overloads |SO3F1 + SO3F2|
%
% Syntax
%   SO3F = SO3F1 + SO3F2
%   SO3F = a + SO3F1
%   SO3F = SO3F1 + a
%
% Input
%  SO3F1, SO3F2 - @SO3FunMLS
%  a - double
%
% Output
%  SO3F - @SO3Fun
%

[SO3F,done] = valueOp(SO3F1,SO3F2,@plus);
if done, return; end

if isa(SO3F2,'SO3FunHarmonic')
  SO3F = SO3F2 + SO3F1;
else
  SO3F = plus@SO3Fun(SO3F1,SO3F2);
end

end
