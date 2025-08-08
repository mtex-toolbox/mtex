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
% tS = v1.tangentSpace;
% v2 = transformTangentSpace(v2,tS);
% 
% ensureCompatibleTangentSpaces(v1,v2,'equal');
% v = dot@vector3d(v1,v2,varargin{:});

% ensure compatible symmetries
em = (SO3VF1.hiddenCS ~= SO3VF2.hiddenCS) || (SO3VF1.hiddenSS ~= SO3VF2.hiddenSS);
if em
  error('The symmetries are not compatible. (Calculations with @SO3VectorField''s needs suitable intern symmetries.)')
end


% make compatible tangent spaces 
SO3VF2.tangentSpace = SO3VF1.tangentSpace;

% standard fallback
fun = @(rot) dot( SO3VF1.eval(rot) , SO3VF2.eval(rot) );
SO3F = SO3FunHandle(fun,SO3VF1.hiddenCS,SO3VF1.hiddenSS);

end