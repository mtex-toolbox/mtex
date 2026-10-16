function S2F = plus(S2F1,S2F2)
% overloads |S2F1 + S2F2|
%
% Syntax
%   S2F = S2F1 + S2F2
%   S2F = a + S2F1
%   S2F = S2F1 + a
%
% Input
%  S2F1, S2F2 - @S2FunMLS
%  a - double
%
% Output
%  S2F - @S2Fun
%

[S2F,done] = valueOp(S2F1,S2F2,@plus);
if done, return; end

if isa(S2F2,'S2FunHarmonic')
  S2F = S2F2 + S2F1;
elseif isa(S2F2,'S2FunMLS')
  % different nodes share no values, the sum stays unevaluated
  S2F = S2FunHandle(@(v) S2F1.eval(v) + S2F2.eval(v),S2F1.frame);
else
  S2F = plus@S2Fun(S2F1,S2F2);
end

end
