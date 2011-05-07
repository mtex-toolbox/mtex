function l = subBoundaryLength(grains)
% returns the length of sub grain boundaries within a grain
%
%% Input
%  grains   - @grain
%
%% Output
%  l - length
%


b = find(hasSubBoundary(grains));
frs = [grains(b).subfractions];
 
l = zeros(size(grains));

for k=1:length(b)
	l(b(k)) = sum(diff(frs(k).xx).^2 + diff(frs(k).yy).^2);
end