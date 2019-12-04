function SO3F = uminus(SO3F)
% implements | -SO3F |

SO3F = SO3FunHandle(@(rot) SO3F.eval(rot));
