function q = quantile(x,n)
% n percent quantile of x 
%
% input: x - double
%        n -
%
% output:

if size(x,1) == 1, x = x.';end
x = sort(x);
q = x(max(1,round(size(x,1)*n)),:);