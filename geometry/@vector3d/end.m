function e = end(v,i,n)
% overloaded end function

if n==1
  e = numel(v.x);
else
  e = size(v,i);
end
