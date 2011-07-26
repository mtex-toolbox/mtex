function e = end(ebsd,i,n)
% overloaded end function

if n==1
	e = numel(ebsd.phases);
else
	e = size(ebsd.phases,i);
end
