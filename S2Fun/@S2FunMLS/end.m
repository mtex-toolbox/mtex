function e = end(S2F,i,n)
% overload end function

s = size(S2F.values);

if n==1
  e = prod(s(2:end));
else
  e = s(i+1);
end
