function S2F = conj(S2F)
% Construct the complex conjugate function $\overline{f}$ of an S2Fun $f$.
%
% Syntax
%   S2F = conj(F)
%
% Input
%  F - @S2FunMLS
%
% Output
%  S2F - @S2FunMLS
%  

S2F.values = conj(S2F.values);

end
