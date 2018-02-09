function e = end(sS,i,n)
% overloaded end function

if n==1
  e = numel(sS.b.x);
else
  e = size(sS.b.x,i);
end
