function SO3VF = uminus(SO3VF)
% overloads |-SO3VF|

SO3VF = SO3VectorFieldHandle(@(v) -SO3VF.eval(v),SO3VF.CS,SO3VF.SS);

end