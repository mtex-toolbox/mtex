function sF = conj(sF)      
% Construct the complex conjugate function $\overline{f}$ of an S1Fun $f$.
%
% Syntax
%   sF = conj(F)
%
% Input
%  F - @S1Fun
%
% Output
%  sF - @S1Fun
%  

sF = S1FunHandle(@(o) conj(sF.eval(o)));

end