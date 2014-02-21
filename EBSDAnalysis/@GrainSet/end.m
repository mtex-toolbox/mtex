function e = end(grains,i,n)
% overloaded end function
	e = nnz(any(grains.I_DG,1));
% else
% 	e = size(grains.phase,i);
% end