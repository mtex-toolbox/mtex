function SO3VF = rotate(SO3VF, rot)
% rotate a SO3 vector field by a rotation
%
% Syntax
%   SO3VF = SO3VF.rotate(rot)
%
% Input
%  SO3VF - @SO3VectorFieldHarmonic
%  rot - @rotation
%
% Output
%  SO3VF - @SO3VectorFieldHarmonic
%

SO3VF.SO3F = rotate(SO3VF.SO3F, rot);


end
