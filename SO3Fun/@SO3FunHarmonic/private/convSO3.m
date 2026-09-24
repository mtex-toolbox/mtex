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
A1 = degreeBlocks(fhat1,L,d);
A2 = degreeBlocks(fhat2,L,d);
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


function A = degreeBlocks(x,L,d)
% the (2l+1) x (2l+1) x ... blocks of the degrees l = 0..L; the entries of a
% sparse vector are sorted into their blocks at once

A = cell(1,L+1);
if issparse(x) && size(x,2) == 1
  [i,~,v] = find(x(1:d(end)));
  i = i(:); v = v(:); d = d(:);
  l = discretize(i,d+1) - 1;
  p = i - d(l+1) - 1;
  for lk = 0:L, A{lk+1} = sparse(2*lk+1,2*lk+1); end
  if isempty(l), return, end
  edges = [0; find(diff(l)); numel(l)];
  for k = 1:numel(edges)-1
    sel = edges(k)+1:edges(k+1);
    n = 2*l(sel(1))+1;
    A{l(sel(1))+1} = sparse(mod(p(sel),n)+1,floor(p(sel)/n)+1,v(sel),n,n);
  end
else
  sz = size(x);
  for lk = 0:L
    A{lk+1} = reshape(x(d(lk+1)+1:d(lk+2),:),[2*lk+1,2*lk+1,sz(2:end)]);
  end
end

end
