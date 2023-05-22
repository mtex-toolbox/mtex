function SO3VF = sqrt(SO3VF, varargin)
% square root of a SO3VectorField
% 
% Syntax
%   SO3VF = sqrt(SO3VF)
%
% Input
%  SO3VF - @SO3VectorField
%
% Output
%  SO3VF - @SO3VectorField
%

SO3VF = SO3VF.^(1/2);

end