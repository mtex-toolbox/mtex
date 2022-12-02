function SO3F = plus(SO3F1,SO3F2)
% overloads |SO3F1 + SO3F2|
%
% Syntax
%   SO3F = SO3F1 + SO3F2
%   SO3F = a + SO3F1
%   SO3F = SO3F1 + a
%
% Input
%  SO3F1, SO3F2 - @SO3FunRBF
%  a - double
%
% Output
%  SO3F - @SO3Fun
%

if isnumeric(SO3F1)
  SO3F = SO3F2;
  SO3F.c0 = SO3F.c0 + SO3F1;
  return
end
if isnumeric(SO3F2)
  SO3F = SO3F1;
  SO3F.c0 = SO3F.c0 + SO3F2;
  return
end

ensureCompatibleSymmetries(SO3F1,SO3F2);
if isa(SO3F1,'SO3FunRBF') && isa(SO3F2,'SO3FunRBF') && ...
    length(SO3F1.center) == length(SO3F2.center) && ...
    all(SO3F1.center(:) == SO3F2.center(:)) && SO3F1.psi == SO3F2.psi
  
  SO3F = SO3F1;
  SO3F.weights = SO3F.weights + SO3F2.weights;
  SO3F.c0 = SO3F.c0 + SO3F2.c0;
  return

elseif isa(SO3F1,'SO3FunRBF') && isa(SO3F2,'SO3FunRBF') && ...
    length(SO3F1.center) < 100 && length(SO3F2.center)<100 && ...
    SO3F1.psi == SO3F2.psi
  
  SO3F = SO3F1;
  SO3F.weights = [SO3F.weights;SO3F2.weights];
  SO3F.center = [SO3F.center;SO3F2.center];
  SO3F.c0 = SO3F.c0 + SO3F2.c0;
  return

end
  
SO3F = plus@SO3Fun(SO3F1,SO3F2);

end


