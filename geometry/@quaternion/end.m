function e = end(q,i,n)
% overloads end function

if n==1
	e = length(q.a);
else
	e = size(q,i);
end
