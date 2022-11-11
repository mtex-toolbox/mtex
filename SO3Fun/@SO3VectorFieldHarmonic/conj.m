function SO3VF = conj(SO3VF)      
% Construct the complex conjugate function $\overline{f}$ of an SO3VectorField $f$.
%
% Syntax
%   SO3VF = conj(F)
%
% Input
%  F - @SO3VectorFieldHarmonic
%
% Output
%  SO3VF - @SO3VectorFieldHarmonic
%  

SO3VF.SO3F = conj(SO3VF.SO3F);


end