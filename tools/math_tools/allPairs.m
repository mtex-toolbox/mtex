function pairs = allPairs(x,y)
% returns all pairs of elements of the vector x
%

if nargin == 1, y = x; end

[x,y] = meshgrid(x,y);

x = x(tril(ones(size(x)))>0);
y = y(tril(ones(size(y)))>0);

pairs = [x(:),y(:)];
