function SO3VF = inv(SO3VF)      
% Define the componentwise inverse function $g$ of an SO3VectorField $f$ 
% by $g(R^{-1}) = f(R)$ for all rotations $R\in SO(3)$.
%
% Syntax
%   SO3VF = inv(F)
%
% Input
%  F - @SO3VectorField
%
% Output
%  SO3F - @SO3VectorFieldHarmonic
%  

tS = SO3VF.tangentSpace;
SO3VF.tangentSpace = SO3VF.internTangentSpace;
SO3VF = SO3VectorFieldHandle(@(r) ...
  SO3VF.eval(inv(r)), SO3VF.hiddenSS, SO3VF.hiddenCS, -SO3VF.tangentSpace);
SO3VF.tangentSpace = tS;

end