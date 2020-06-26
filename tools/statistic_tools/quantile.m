function q = quantile(x,n)
% n percent quantile of x 
%
% Input
% x - double
% n -
%
% Output

if size(x,1) == 1, x = x.';end
x = sort(x);

if isempty(x),
  q = [];
elseif n <= 0
  q = x(max(1,end+n));
elseif n < 1
  q = x(max(1,round(size(x,1)*n)),:);
else
  q = x(min(n,numel(x)));
end
