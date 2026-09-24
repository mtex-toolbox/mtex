function A = degreeBlocks(x,L)
% the degree blocks of a vector of Wigner coefficients
%
% Description
% The Wigner coefficients of degree l are the (2l+1) x (2l+1) entries
% deg2dim(l)+1:deg2dim(l+1) of x in column major order. A sparse vector
% is sorted into its blocks at once instead of being searched for every
% degree.
%
% Syntax
%   A = degreeBlocks(x,L)
%
% Input
%  x - Wigner coefficients, a column per function
%  L - maximum degree
%
% Output
%  A - cell with the blocks of the degrees 0..L, (2l+1) x (2l+1) x ...
%

d = (0:L+1).*(4*(0:L+1).^2-1)/3;   % deg2dim(0:L+1)
A = cell(1,L+1);
if issparse(x) && size(x,2) == 1
  for l = 0:L, A{l+1} = sparse(2*l+1,2*l+1); end
  [i,~,v] = find(x(1:d(end)));
  if isempty(i), return, end
  i = i(:); v = v(:);
  l = discretize(i,d+1) - 1;
  p = i - d(l+1).' - 1;
  edges = [0; find(diff(l)); numel(l)];
  for k = 1:numel(edges)-1
    sel = edges(k)+1:edges(k+1);
    n = 2*l(sel(1))+1;
    A{l(sel(1))+1} = sparse(mod(p(sel),n)+1,floor(p(sel)/n)+1,v(sel),n,n);
  end
else
  sz = size(x);
  for l = 0:L
    A{l+1} = reshape(x(d(l+1)+1:d(l+2),:),[2*l+1,2*l+1,sz(2:end)]);
  end
end

end
