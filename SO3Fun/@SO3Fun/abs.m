function SO3F = abs(SO3F)

SO3F = SO3FunHandle(@(rot) abs(SO3F.eval(rot)));