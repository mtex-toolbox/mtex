function fhat = convSO3(fhat1,fhat2)
% compute the convolution w.r.t. the coefficient vectors
%
% $$ \hat{f}_n^{k,l} = \frac{1}{\sqrt{2n+1}} \, \sum_{j=-n}^{n} \hat{f_1}_n^{k,j} \cdot \hat{f_2}_n^{j,l}$$
%

% old sizes
s1 = size(fhat1);
s2 = size(fhat2);

% get bandwidth
L = min(dim2deg(s1(1)),dim2deg(s2(1)));

% new size
l = length(s2)-length(s1);
s = max([s1(2:end),ones(1,l);s2(2:end),ones(1,-l)]);

% compute Fourier coefficients of the convolution degree by degree
d = (0:L+1).*(4*(0:L+1).^2-1)/3;   % deg2dim(0:L+1)
A1 = degreeBlocks(fhat1,L);
A2 = degreeBlocks(fhat2,L);
fhat = zeros([d(end),s]);
for l = 0:L
  ind = d(l+1)+1:d(l+2);
  if prod(s) == 1 % simple SO3Fun
    fhat(ind) = A2{l+1} * A1{l+1} ./ sqrt(2*l+1);
  else % vector valued SO3Fun
    fhat(ind,:) = reshape(pagemtimes(full(A2{l+1}),full(A1{l+1})),[],prod(s)) ./ sqrt(2*l+1);
  end
end

end

