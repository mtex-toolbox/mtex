function e = end(grains,i,n)
% overloaded end function

if n==1
	e = numel(grains.phase);
else
	e = size(grains.phase,i);
end