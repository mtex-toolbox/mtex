function SO3VF = plus(SO3VF1,SO3VF2)
% overloads |SO3VF1 + SO3VF2|
%
% Syntax
%   SO3VF = SO3VF1 + SO3VF2
%
% Input
%  SO3VF1, SO3VF2 - @SO3VectorField
%
% Output
%  SO3VF - @SO3VectorField
%

if ~isa(SO3VF1,'SO3VectorField') || ~isa(SO3VF2,'SO3VectorField')
  error('In case of SO3VectorFields, it only make sense to sum with other SO3VectorFields.')
end


% ensure compatible symmetries
em = (SO3VF1.hiddenCS ~= SO3VF2.hiddenCS) || (SO3VF1.hiddenSS ~= SO3VF2.hiddenSS);
if em
  error('The symmetries are not compatible. (Calculations with @SO3VectorField''s needs suitable intern symmetries.)')
end


% get tangent space and make compatible 
% (When there are multiple concatenations, we try to prevent the tangential space from switching back and forth repeatedly.)
tS = SO3VF1.tangentSpace;
tS_I = SO3VF1.internTangentSpace;
SO3VF1.tangentSpace = tS_I;
SO3VF2.tangentSpace = tS_I;

% standard fallback
fun = @(rot) SO3VF1.eval(rot) + SO3VF2.eval(rot);
SO3VF = SO3VectorFieldHandle(fun,SO3VF1.hiddenCS,SO3VF1.hiddenSS,tS_I);
SO3VF.tangentSpace = tS;

end