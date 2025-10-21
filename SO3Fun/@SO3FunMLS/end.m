function e = end(SO3F,i,n)
% overload end function

s = size(SO3F.values);

if n==1
  e = prod(s(2:end));
else
  e = s(i+1);
end
