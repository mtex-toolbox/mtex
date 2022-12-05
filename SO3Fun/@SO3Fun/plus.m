function SO3F = plus(SO3F1,SO3F2)
% overloads |SO3F1 + SO3F2|
%
% Syntax
%   SO3F = SO3F1 + SO3F2
%   SO3F = a + SO3F1
%   SO3F = SO3F1 + a
%
% Input
%  SO3F1, SO3F2 - @SO3Fun
%  a - double
%
% Output
%  SO3F - @SO3Fun
%

% uniform component + SO3Fun
if isa(SO3F1,'SO3FunRBF') && isempty(SO3F1.center) && isa(SO3F2,'SO3Fun') 
  SO3F = SO3F1.c0 + SO3F2;
  return
end
if isa(SO3F2,'SO3FunRBF') && isempty(SO3F2.center) && isa(SO3F1,'SO3Fun') 
  SO3F = SO3F1 + SO3F2.c0;
  return
end

ensureCompatibleSymmetries(SO3F1,SO3F2);
SO3F = SO3FunComposition(SO3F1, SO3F2);
  
end