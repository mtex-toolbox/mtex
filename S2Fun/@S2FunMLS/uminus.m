function S2F = uminus(S2F)
% the negative of a spherical function
%
% Syntax
%   S2F = -S2F
%
% Input
%  S2F - @S2FunMLS
%
% Output
%  S2F - @S2FunMLS

S2F.values = -S2F.values;

end
