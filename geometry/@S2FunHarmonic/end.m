function e = end(sF,i,n)
% overloaded end function

s = size(sF.fhat);

if n==1
  e = prod(s(2:end));
else
  e = s(i+1);
end
