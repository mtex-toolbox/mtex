function [u,ind] = cunion(s,eqfun)
% disjoint union 

if isempty(s)
	u = [];
    return
else
		
	if isa(s,'double')
		u = s(1);
    ind = 1;
		
		for i=1:length(s)
			if ~any(isnull(abs(u-s(i))))
				u = [u,s(i)]; %#ok<AGROW>
        ind = [ind,i];%#ok<AGROW>
			end
		end
	else
		u = s(1);
    ind = 1;
    if nargin == 1, eqfun = @(a,b) isnull(norm(a-b));end
		
		for i=1:length(s)
			if ~any(eqfun(u,s(i)))
				u = [u,s(i)]; %#ok<AGROW>
        ind = [ind,i]; %#ok<AGROW>
			end
		end
	end
end
