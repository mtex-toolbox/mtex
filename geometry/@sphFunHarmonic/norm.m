function n = norm(sF)
% the L2 norm of a spherical function
%
% Syntax
%  norm(sF)
%

n = sqrt(sum(abs(sF.fhat).^2));

end
