function SO3F = conj(SO3F)
% Construct the complex conjugate function $\overline{f}$ of an SO3Fun $f$.
%
% Syntax
%   SO3F = conj(F)
%
% Input
%  F - @SO3FunMLS
%
% Output
%  SO3F - @SO3FunMLS
%  

SO3F.values = conj(SO3F.values);

end
