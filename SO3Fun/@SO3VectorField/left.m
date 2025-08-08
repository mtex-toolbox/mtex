function SO3VF = left(SO3VF,varargin)
% change the representation of the tangent vectors to left sided
%
% Syntax
%   SO3VF = left(SO3VF)
%
% Input
%  SO3VF - @SO3VectorField
%
% Output
%  SO3VF - @SO3VectorField  (the evaluation directly gives left-sided tangent vectors)
%

% change outer tangent space representation to left
SO3VF.tangentSpace = abs(SO3VF.tangentSpace);

% TODO: Flag InternTangentSpace

end