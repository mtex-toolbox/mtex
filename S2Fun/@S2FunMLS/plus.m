function S2F = plus(S2F1, S2F2)
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

if isnumeric(S2F1)
  S2F = S2F2;
  S2F.values = S2F.values + reshape(S2F1,[1 size(S2F1)]);
  return
end
if isnumeric(S2F2)
  S2F = S2F2 + S2F1;
  return
end

ensureCompatibleSymmetries(S2F1,S2F2);

if (isa(S2F2, 'S2FunHarmonic'))
  S2F = S2F2 + S2F1;
  return;
end

% adding the values only works on a shared set of nodes
if isa(S2F1,'S2FunMLS') && isa(S2F2,'S2FunMLS') && ...
    length(S2F1.nodes) == length(S2F2.nodes) && ...
    all(S2F1.nodes(:) == S2F2.nodes(:))

  S2F = S2F1;
  S2F.values = S2F.values + S2F2.values;
  return

end

% two node sets that do not match have no common values array, so leave the sum unevaluated
if isa(S2F2,'S2FunMLS')
  S2F = S2FunHandle(@(v) S2F1.eval(v) + S2F2.eval(v), S2F1.frame);
  return
end

S2F = plus@S2Fun(S2F1,S2F2);

end
