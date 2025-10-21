function e = end(SO3F,i,n)
% overload end function

s = size(SO3F);

if n==1
  e = prod(s);
else
  e = s(i);
end
