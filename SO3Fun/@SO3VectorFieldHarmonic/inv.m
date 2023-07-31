function SO3VF = inv(SO3VF)      
% Define the componentwise inverse function $g$ of an SO3VectorField $f$ 
% by $g(R^{-1}) = f(R)$ for all rotations $R\in SO(3)$.
%
% Syntax
%   SO3VF = inv(F)
%
% Input
%  F - @SO3VectorFieldHarmonic
%
% Output
%  SO3F - @SO3VectorFieldHarmonic
%  

error(['Result of the inversion of SO3VectorFields is not clear.' ...
       'Does the tangent space change or not? What about the symmetries?'])

% SO3VF.SO3F = inv(SO3VF.SO3F);

%SO3VF = SO3VectorFieldHandle(@(r) SO3VF.eval(inv(r)),SO3VF.SS,SO3VF.CS);

end