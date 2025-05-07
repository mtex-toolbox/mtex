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
  if isscalar(SO3F1)
    SO3F = SO3FunHandle(@(rot) SO3F1 ./ SO3F2.eval(rot),SO3F2.SRight,SO3F2.SLeft);
  else
    SO3F = SO3FunHandle(@(rot) reshape(SO3F1,[1 size(SO3F1)]) ./ reshape(SO3F2.eval(rot),[numel(rot) size(SO3F2)]),SO3F2.SRight,SO3F2.SLeft);
  end
  return
end

SO3F = times(SO3F1,1./SO3F2);

end

