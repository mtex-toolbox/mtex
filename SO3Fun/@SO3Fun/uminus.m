function SO3F = uminus(SO3F)
% overloads |-SO3F|

SO3F = SO3FunHandle(@(rot) -SO3F.eval(rot),SO3F.CS,SO3F.SS);

end