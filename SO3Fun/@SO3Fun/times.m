function SO3F = times(SO3F1,SO3F2)
% implements .* 

if isa(SO3F1,'SO3Fun') && isa(SO3F2,'SO3Fun')
  
  % TODO: check for compatible symmetries!
  SO3F = SO3FunHandle(@(rot) SO3F1.eval(rot) .* SO3F2.eval(rot),SO3F1.CS,SO3F1.SS);
  
elseif isa(SO3F1,'SO3Fun')
  
  SO3F = SO3FunHandle(@(rot) SO3F1.eval(rot) .* SO3F2,SO3F1.CS,SO3F1.SS);
  
else
  
  SO3F = SO3FunHandle(@(rot) SO3F1 .* SO3F2.eval(rot),SO3F2.CS,SO3F2.SS);
  
end

