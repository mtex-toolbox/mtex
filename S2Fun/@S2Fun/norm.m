function n = norm(sF)
% the L2 norm of a spherical function
%
% Syntax
%   norm(sF)
%
% Input
%  sF - @S2Fun
%

F = S2FunHandle(@(v) abs(sF.eval(v)).^2);
n = sqrt(sum(F));

end