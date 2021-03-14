function n = norm(SO3F)
% the L2 norm of SO3FunHarmonics
%
% Syntax
%   norm(SO3F)
%

% It is easy to show
% \| SO3F \|^2_{L^2} = \sum |fhat_{n,k,l}|^2 \| D_{k,l}^n \|^2_{L^2},
% because the inner product of different Wigner-D functions is 0.
% With {Fast Fourier Algorithm on the Rotation Group, Antje Vollrath,
% section 2.1} it follows  
% \| D_{k,l}^n \|^2_{L^2} = 8*pi^2/(2*n+1)
% and hence we get the norm by correcting it with 8*pi^2/(2*n+1)

s = size(SO3F);
SO3F = SO3F.subSet(':');
n = pi*sqrt(8 * sum( SO3F.power , 1));
n = reshape(n, s);

end
