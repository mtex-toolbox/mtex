function SO3VF = normalize(SO3VF)
% Gives the normal vector of the tangential plane in v
%

% prevent additional quadrature
f = SO3VectorFieldHandle(@(r) normalize(SO3VF.eval(r)),SO3VF.CS,SO3VF.SS);
SO3VF = SO3VectorFieldRBF(f);

end
