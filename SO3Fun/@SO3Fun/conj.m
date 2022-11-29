function SO3F = conj(SO3F)      
% Construct the complex conjugate function $\overline{f}$ of an SO3Fun $f$.
%
% Syntax
%   SO3F = conj(F)
%
% Input
%  F - @SO3Fun
%
% Output
%  SO3F - @SO3FunHarmonic
%  

SO3F = SO3FunHandle(@(rot) conj(SO3F.eval(rot)),SO3F.SRight,SO3F.SLeft);
% SO3F = SO3FunHarmonic(SO3F);
% SO3F = conj(SO3F);

end