function e = end(ebsd,i,n)
% overloaded end function

if n==1
	e = numel(ebsd.phase);
else
	e = size(ebsd.phase,i);
end
