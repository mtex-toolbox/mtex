function SO3VF = minus(SO3VF1,SO3VF2)
% overloads |SO3VF1 - SO3VF2|
%
% Syntax
%   SO3VF = SO3VF1 - SO3VF2
%   SO3VF = a - SO3VF1
%   SO3VF = SO3VF1 - a
%
% Input
%  SO3VF1, SO3VF2 - @SO3VectorField
%  a - double
%
% Output
%  SO3VF - @SO3VectorField
%

SO3VF = plus(SO3VF1,-SO3VF2);
        
end