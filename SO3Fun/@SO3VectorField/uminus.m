function SO3VF = uminus(SO3VF)
% overloads |-SO3VF|

tS = SO3VF.tangentSpace;
SO3VF.tangentSpace = SO3VF.internTangentSpace;
SO3VF = SO3VectorFieldHandle(@(v) -SO3VF.eval(v),SO3VF.hiddenCS,SO3VF.hiddenSS,SO3VF.tangentSpace);
SO3VF.tangentSpace = tS;

end