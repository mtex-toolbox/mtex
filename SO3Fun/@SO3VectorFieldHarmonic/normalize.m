function SO3VF = normalize(SO3VF)
% Gives the normal vector of the tangential plane in v
%

% prevent additional quadrature
SO3VF = SO3VF ./ norm@SO3VectorField(SO3VF);
SO3VF = SO3VectorFieldHarmonic(SO3VF);

end
