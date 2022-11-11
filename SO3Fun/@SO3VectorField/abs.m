function SO3VF = abs(F)
% overloads the componentwise absolute value |abs(SO3VF)| 
%
% Note that abs is not the length of a vector3d which is the evaluation of
% the SO3VectorField in one rotation.
%
% one 
%
% Syntax
%   SO3VF = abs(SO3VF)
%
% Input
%  SO3VF - @SO3VectorField
%
% Output
%  SO3VF - @SO3VectorField
%

SO3VF = SO3VectorFieldHandle(@(rot) g(rot),F.SRight,F.SLeft);

function g = g(rot)
g = F.eval(rot);
g = vector3d(abs(g.xyz.'));
end

end