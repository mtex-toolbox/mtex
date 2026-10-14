function sF = uminus(sF)
% the negative of a spherical function
%
% Syntax
%
%   sF = -sF
%
% Input
%  sF - @S2FunHarmonic
%
% Output
%  sF - @S2FunHarmonic

sF.fhat = -sF.fhat;

end
