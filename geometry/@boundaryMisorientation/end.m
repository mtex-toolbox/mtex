function e = end(bM,i,n)
% overloads end function

if n==1
	e = numel(bM.mori);
else
	e = size(bM,i);
end
