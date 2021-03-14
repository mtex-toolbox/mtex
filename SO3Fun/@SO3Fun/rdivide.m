function SO3F = rdivide(SO3F1, SO3F2)
% implements ./

if isa(SO3F1,'SO3Fun') && isa(SO3F2,'SO3Fun')
  
  SO3F = SO3FunHandle(@(rot) SO3F1.eval(rot) ./ SO3F2.eval(rot));
  
elseif isa(SO3F1,'SO3Fun')
  
  SO3F = SO3FunHandle(@(rot) SO3F1.eval(rot) .*(1./SO3F2));
  
else
  
  SO3F = SO3FunHandle(@(rot) SO3F1 .* SO3F2.eval(rot));
  
end


end

