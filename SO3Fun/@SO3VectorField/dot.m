function SO3F = dot(SO3VF1, SO3VF2, varargin)
% pointwise inner product
%
% Syntax
%   SO3F = dot(SO3VF1, SO3VF2)
%
% Input
%   SO3VF1, SO3VF2 - @SO3VectorField
%
% Output
%   SO3F - @SO3Fun
%

if ~isa(SO3VF1,'SO3VectorField') ||  ~isa(SO3VF2,'SO3VectorField') 
  error('For SO3VectorFields, it only make sense to calculate the pointwise dot product with other SO3VectorFields.')
end


ensureCompatibleSymmetries(SO3VF1,SO3VF2)


% make compatible tangent spaces 
SO3VF2.tangentSpace = SO3VF1.tangentSpace;

% standard fallback
fun = @(rot) dot( SO3VF1.eval(rot) , SO3VF2.eval(rot) );
SO3F = SO3FunHandle(fun,SO3VF1.hiddenCS,SO3VF1.hiddenSS);

end