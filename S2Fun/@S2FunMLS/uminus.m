function sF = uminus(sF)
% the negative of a spherical function
%
% Syntax
%
%   sF = -sF
%
% Input
%  sF - @S2FunMLS
%
% Output
%  sF - @S2FunMLS

sF.values = -sF.values;

end
