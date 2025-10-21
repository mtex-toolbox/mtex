function SO3F = times(SO3F1,SO3F2)
% overloads |SO3F1 .* SO3F2|
%
% Syntax
%   sF = SO3F1 .* SO3F2
%   sF = a .* SO3F2
%   sF = SO3F1 .* a
%
% Input
%  SO3F1, SO3F2 - @SO3Fun
%  a - double
%
% Output
%  SO3F - @SO3Fun
%

% uniform component .* SO3Fun
if isa(SO3F1,'SO3FunRBF') && isempty(SO3F1.center) && isa(SO3F2,'SO3Fun') 
  SO3F = SO3F1.c0 .* SO3F2;
  return
end
if isa(SO3F2,'SO3FunRBF') && isempty(SO3F2.center) && isa(SO3F1,'SO3Fun') 
  SO3F = SO3F1 .* SO3F2.c0;
  return
end

if isnumeric(SO3F1)
  if isscalar(SO3F1)
    SO3F = SO3FunHandle(@(rot) SO3F1 .* SO3F2.eval(rot),SO3F2.SRight,SO3F2.SLeft);
  else
    SO3F = SO3FunHandle(@(rot) reshape(SO3F1,[1 size(SO3F1)]) .* reshape(SO3F2.eval(rot),[numel(rot) size(SO3F2)]),SO3F2.SRight,SO3F2.SLeft);
  end
  return
end

if isnumeric(SO3F2)
  SO3F = SO3F2 .* SO3F1;
  return
end

ensureCompatibleSymmetries(SO3F1,SO3F2);
if isa(SO3F2,'SO3VectorField')
  SO3F = SO3VectorFieldHandle(@(rot) SO3F1.eval(rot) .* SO3F2.eval(rot),SO3F1.SRight,SO3F1.SLeft);
elseif isscalar(SO3F1) && isscalar(SO3F2)
  SO3F = SO3FunHandle(@(rot) SO3F1.eval(rot) .* SO3F2.eval(rot),SO3F1.SRight,SO3F1.SLeft);
else
  SO3F = SO3FunHandle(@(rot) reshape(SO3F1.eval(rot),[numel(rot) size(SO3F1)]) .* reshape(SO3F2.eval(rot),[numel(rot) size(SO3F2)]),SO3F1.SRight,SO3F1.SLeft);
end

end