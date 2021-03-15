function n = norm(SO3F)
% the L2 norm of SO3FunHarmonics
%
% Syntax
%   norm(SO3F)
%

% norm of Wigner-D functions is 1

s = size(SO3F);
SO3F = SO3F.subSet(':');
n = sqrt(sum(abs(SO3F.fhat).^2, 1));
n = reshape(n, s);

end
