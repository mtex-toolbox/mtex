function SO3F = times(SO3F1,SO3F2)
% overloads |SO3F1 .* SO3F2|
%
% Syntax
%   sF = SO3F1 .* SO3F2
%   sF = a .* SO3F2
%   sF = SO3F1 .* a
%
% Input
%  SO3F1, SO3F2 - @SO3FunComposition
%  a - double
%
% Output
%  SO3F - @SO3Fun
%

if isnumeric(SO3F1)
  components = cellfun(@(x) SO3F1.*x,SO3F2.components,'UniformOutput',false);
  SO3F = SO3F2;
  SO3F.components = components;
end

SO3F = times@SO3Fun(SO3F1,SO3F2);

end