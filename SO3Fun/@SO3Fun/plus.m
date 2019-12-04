function SO3F = plus(SO3F1,SO3F2)
% implements |SO3F1 + SO3F2|

if isa(x,'SO3Fun') && isa(y,'SO3Fun')
  
  SO3F = SO3FunHandle(@(rot) SO3F1.eval(rot) + SO3F2.eval(rot));
  
elseif isa(x,'SO3Fun')
  
  SO3F = SO3FunHandle(@(rot) SO3F1.eval(rot) + SO3F2);
  
else
  
  SO3F = SO3FunHandle(@(rot) SO3F1 + SO3F2.eval(rot));
  
end