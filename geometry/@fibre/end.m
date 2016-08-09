function e = end(f,i,n)
% overloaded end function

if n==1
	e = numel(f.r);
else
	e = size(f.r,i);
end
