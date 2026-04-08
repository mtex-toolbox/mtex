function SO3VF = cross(SO3VF1, SO3VF2, varargin)
% pointwise cross product
%
% Syntax
%   SO3VF = cross(SO3VF1, SO3VF2)
%
% Input
%   SO3VF1, SO3VF2 - @SO3VectorField
%
% Output
%   SO3VF - @SO3VectorField
%

if ~isa(SO3VF1,'SO3VectorField') ||  ~isa(SO3VF2,'SO3VectorField')
  error('For SO3VectorFields, it only make sense to calculate the pointwise cross product with other SO3VectorFields.')
end


ensureCompatibleSymmetries(SO3VF1,SO3VF2)


% get tangent space and make compatible 
% (When there are multiple concatenations, we try to prevent the tangential space from switching back and forth repeatedly.)
tS = SO3VF1.tangentSpace;
tS_I = SO3VF1.internTangentSpace;
SO3VF1.tangentSpace = tS_I;
SO3VF2.tangentSpace = tS_I;

% standard fallback
fun = @(rot) cross( SO3VF1.eval(rot) , SO3VF2.eval(rot) );
SO3VF = SO3VectorFieldHandle(fun,SO3VF1.hiddenCS,SO3VF1.hiddenSS,tS_I);
SO3VF.tangentSpace = tS;

end