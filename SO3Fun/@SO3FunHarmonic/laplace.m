function SO3F = laplace(SO3F)
%
% Syntax
%   SO3F = SO3F1.laplace
%
% Input
%  SO3F - @SO3FunHarmonic
%
% Output
%  SO3F - @SO3FunHarmonic
%
% See also
% SO3Kernel/conv SO3FunHarmonic/conv

L = SO3F.bandwidth;
l = 0:L;

psi = SO3Kernel(-l.*(l+1).*(2*l+1));

SO3F = conv(SO3F,psi);

end

