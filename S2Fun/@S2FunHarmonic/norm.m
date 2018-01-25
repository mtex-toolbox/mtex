function n = norm(sF)
% the L2 norm of a spherical function
%
% Syntax
%   norm(sF)
%

s = size(sF);
sF = sF.subSet(':');
n = sqrt(sum(abs(sF.fhat).^2, 1));
n = reshape(n, s);

end
