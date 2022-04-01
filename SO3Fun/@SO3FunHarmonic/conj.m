function SO3F = conj(SO3F)
% Construct the complex conjugate function $\overline{f}$ of an SO3Fun $f$.
%
% Syntax
%   SO3F = conj(F)
%
% Input
%  F - @SO3FunHarmonic
%
% Output
%  SO3F - @SO3FunHarmonic
%  

bw = SO3F.bandwidth;
for n=0:bw
  ind = deg2dim(n)+1:deg2dim(n+1);
  ind2 = flip(ind);
  SO3F.fhat(ind,:) = SO3F.fhat(ind2,:);
end
SO3F.fhat = conj(SO3F.fhat);

end
