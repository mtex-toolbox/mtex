function SO3F = inv(SO3F)      
% Define the inverse function $g$ of an SO3Fun $f$ by $g(R^{-1}) = f(R)$
% for all rotations $R\in SO(3)$.
%
% Syntax
%   SO3F = inv(F)
%
% Input
%  F - @SO3Fun
%
% Output
%  SO3F - @SO3FunHarmonic
%  

SO3F = SO3FunHarmonic(SO3F);
SO3F = inv(SO3F);

end