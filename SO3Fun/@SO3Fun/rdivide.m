function SO3F = rdivide(SO3F1, SO3F2)
% overloads ./
%
% Syntax
%   SO3F = SO3F1 ./ SO3F2
%   SO3F = SO3F1 ./ a
%   SO3F = a ./ SO3F2
%
% Input
%  SO3F1, SO3F2 - @SO3Fun
%  a - double
%
% Output
%  SO3F - @SO3Fun
%

if isnumeric(SO3F1)
  SO3F = SO3FunHandle(@(rot) SO3F1./ SO3F2.eval(rot),SO3F2.SRight,SO3F2.SLeft);
  return
end

SO3F = times(SO3F1,1./SO3F2);

end

