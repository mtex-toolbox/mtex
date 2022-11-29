function SO3F = uminus(SO3F)
% overloads |-SO3F|

components = cellfun(@(x) -x,SO3F.components,'UniformOutput',false);
SO3F.components = components;

end