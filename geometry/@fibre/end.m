function e = end(f,i,n)
% overloaded end function

if n==1
  e = numel(f.o1);
else
  e = size(f.o1,i);
end
