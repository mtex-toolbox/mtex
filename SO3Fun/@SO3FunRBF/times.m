function SO3F = times(SO3F1,SO3F2)
% overloads |SO3F1 .* SO3F2|
%
% Syntax
%   sF = SO3F1 .* SO3F2
%   sF = a .* SO3F2
%   sF = SO3F1 .* a
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
  SO3F.weights = SO3F.weights .* SO3F1;
  SO3F.c0 = SO3F.c0 .* SO3F1;  
  return
end  

SO3F = times@SO3Fun(SO3F1,SO3F2);

end
