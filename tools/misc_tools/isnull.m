function b = isnull(x,eps)
% ckeck double == 0

if nargin == 1, eps = 1e-14; end

b = abs(x)<=eps;
