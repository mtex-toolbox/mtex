function SO3VF = conj(SO3VF)      
% Construct the complex conjugate function $\overline{f}$ of an SO3VectorField $f$.
%
% Syntax
%   SO3VF = conj(F)
%
% Input
%  F - @SO3VectorField
%
% Output
%  SO3VF - @SO3VectorField
%  

SO3VF = SO3VectorFieldHandle(@(rot) conj(SO3VF.eval(rot)),SO3VF.SRight,SO3VF.SLeft);


end