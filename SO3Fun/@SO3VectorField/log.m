function SO3VF = log(F)
% overloads |log(SO3VF)|
%
% Syntax
%   SO3VF = log(SO3VF)
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
g = vector3d(log(g.xyz.'));
end

end