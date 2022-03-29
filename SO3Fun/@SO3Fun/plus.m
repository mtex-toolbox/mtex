function SO3F = plus(SO3F1,SO3F2)
% implements |SO3F1 + SO3F2|

if isa(SO3F2,'SO3FunHarmonic')

  SO3F = SO3F2 + SO3F1;
  return
end

SO3F = SO3FunComposition(SO3F1, SO3F2);
  
end