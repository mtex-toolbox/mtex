function SO3VF = exp(F)
% overloads |exp(SO3VF)|
%
% Syntax
%   SO3VF = exp(SO3VF)
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
g = vector3d(exp(g.xyz.'));
end

end