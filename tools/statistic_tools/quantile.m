function q = quantile(x,n)
% n percent quantile of x 
%
%% Input
% x - double
%  n -
%
%% Output

if size(x,1) == 1, x = x.';end
x = sort(x);
q = x(max(1,round(size(x,1)*n)),:);
