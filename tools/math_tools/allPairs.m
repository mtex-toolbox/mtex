function [x,y] = allPairs(x,y)
% all pairs of elements of x and y modulo permutation
%

if nargin == 1

  [x,y] = meshgrid(x,x);

  x = x(tril(ones(size(x)))>0);
  y = y(tril(ones(size(y)))>0);
  
else
  
  %
  x = x(:);
  y = y(:);
  iseq = bsxfun(@eq,x,y.');
  
  [ix,iy] = find(iseq);
  
  x = [x(ix);x(~any(iseq,2))];
  y = [y(iy);y(~any(iseq,1))];
  
  % all pairs
  [x,y] = meshgrid(x,y);

  % remove double pars
  A = zeros(size(x));
  A(1:length(ix),1:length(ix)) = 1;
  A = ~triu(A,1);
  
  x = x(A);
  y = y(A);
  
end

if nargout < 2, x = [x(:),y(:)]; end
