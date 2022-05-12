function SO3F = smooth(SO3F,psi)
% smooth SO3FunHarmonic
%
% Input
%  SO3F - @SO3FunHarmonic
%  res - resolution
%
% Output
%  component - smoothed @SO3FunHarmonic
%

L = min(SO3F.bandwidth,find(psi.A,1,'last')-1);

SO3F.fhat = SO3F.fhat(1:deg2dim(L+1));
for l = 0:L
  SO3F.fhat(deg2dim(l)+1:deg2dim(l+1)) = ...
    SO3F.fhat(deg2dim(l)+1:deg2dim(l+1)) * psi.A(l+1);
end
