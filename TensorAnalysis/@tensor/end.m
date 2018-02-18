function e = end(T,i,n)
% overloaded end function

if n==1
  e = prod(size(T)); %#ok<PSIZE>
else
  e = size(T,i);
end
