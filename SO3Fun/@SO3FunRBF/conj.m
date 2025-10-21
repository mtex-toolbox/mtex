function SO3F = conj(SO3F)
% Construct the complex conjugate function $\overline{f}$ of an SO3Fun $f$.
%
% Syntax
%   SO3F = conj(F)
%
% Input
%  F - @SO3FunRBF
%
% Output
%  SO3F - @SO3FunRBF
%  

SO3F.c0 = conj(SO3F.c0);
SO3F.weights = conj(SO3F.weights);

end
