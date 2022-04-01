function SO3F = uminus(SO3F)
% overloads |-SO3F|

SO3F.weights = -SO3F.weights;
SO3F.c0 = -SO3F.c0;

end