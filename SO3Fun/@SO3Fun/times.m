function SO3F = times(SO3F1,SO3F2)
% implements .* 

if isa(x,'SO3Fun') && isa(y,'SO3Fun')
  
  SO3F = SO3FunHandle(@(rot) SO3F1.eval(rot) .* SO3F2.eval(rot));
  
elseif isa(x,'SO3Fun')
  
  SO3F = SO3FunHandle(@(rot) SO3F1.eval(rot) .* SO3F2);
  
else
  
  SO3F = SO3FunHandle(@(rot) SO3F1 .* SO3F2.eval(rot));
  
end

