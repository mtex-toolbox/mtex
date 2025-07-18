function SO3VF = right(SO3VF,varargin)
% change the representation of the tangent vectors to right sided
%
% Syntax
%   SO3VF = right(SO3VF)
%
% Input
%  SO3VF - @SO3VectorField
%
% Output
%  SO3VF - @SO3VectorField  (the evaluation directly gives right-sided tangent vectors)
%

% change outer tangent space representation to right
SO3VF.tangentSpace = -abs(SO3VF.tangentSpace);

end