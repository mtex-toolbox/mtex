function e = end(ebsd,i,n)
% overloaded end function
%
% Syntax
%   ebsd(1:end)


if n==1
	e = numel(ebsd.phaseId);
else
	e = size(ebsd.phaseId,i);
end
