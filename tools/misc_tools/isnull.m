function b = isnull(x,eps)
% check double == 0

if nargin == 1, eps = 1e-10; end

b = abs(x)<=eps;
