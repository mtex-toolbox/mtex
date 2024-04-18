function n = norm(SO3F,SobolevIndex)
% Calculate the L2-norm also known as texture index of a SO3FunHarmonic, by
% using Parsevalls equality for the integral
%
% $$ t = \sqrt{\frac1{8\pi^2}\int_{SO(3)} |f( R ) |^2 dR},$$
%
% with $vol(SO(3)) = \int_{SO(3)} 1 dR = 8\pi^2$. 
% The Wigner-D functions (one Wigner-coefficient is 1 and all others are 0) 
% are L2-normalized.
%
% We can compute the Sobolev norm of an SO3FunHarmonic by
%
% $$ t = \sqrt{ \sum_{n=0}^N (2n+1)^{2s} \, \sum_{k,l=-n}^n \abs{\hat{f}_n^{k,l}}^2 },$$
%
% where $s$ is the Sobolev index. (The default case $s=0$ corresponds to the L2-norm.)
%
% Syntax
%   t = norm(SO3F)
%   t = norm(SO3F,'Sobolev')
% 
% Input
%  SO3F - @SO3FunHarmonic
%
% Output
%  t - double
%
% Options
%  resolution  - choose mesh width by calculation of mean
%

if nargin==1
  SobolevIndex = 0;
end
if SobolevIndex>0
  psi = SO3Kernel((2*(0:SO3F.bandwidth)+1).^(1+SobolevIndex));
  SO3F = conv(SO3F,psi);
end

s = size(SO3F);
n = sqrt(sum(abs(SO3F.fhat).^2, 1));
n = reshape(n, s);

end
