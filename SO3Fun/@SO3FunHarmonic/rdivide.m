function SO3F = rdivide(SO3F1, SO3F2)
% overloads ./
%
% Syntax
%   SO3F = SO3F1 ./ SO3F2
%   SO3F = SO3F1 ./ a
%   SO3F = a ./ SO3F2
%
% Input
%  SO3F1, SO3F2 - @SO3FunHarmonic
%  a - double
%
% Output
%  SO3F - @SO3FunHarmonic
%


if isnumeric(SO3F1)
  SO3F = SO3FunHandle(@(rot) SO3F1 ./ SO3F2.eval(rot),SO3F2.SRight,SO3F2.SLeft);
  SO3F = SO3FunHarmonic(SO3F, 'bandwidth', min(getMTEXpref('maxSO3Bandwidth'),2*SO3F2.bandwidth));
  return
end
if isnumeric(SO3F2)
  SO3F = times(SO3F1,1./SO3F2);
  return
end

ensureCompatibleSymmetries(SO3F1,SO3F2);
SO3F = SO3FunHandle(@(rot) SO3F1.eval(rot)./ SO3F2.eval(rot),SO3F1.SRight,SO3F1.SLeft);
SO3F = SO3FunHarmonic(SO3F, 'bandwidth', min(getMTEXpref('maxSO3Bandwidth'),2*max(SO3F1.bandwidth, SO3F2.bandwidth)));

end

