function [a,count] = nanplus(a,b,count,alpha)

if nargin < 4
  alpha = 1;
elseif isnan(alpha)
  return; 
end
ind = ~isnan(b);

a(ind) = a(ind) + alpha * b(ind);
count = count + alpha * ind;