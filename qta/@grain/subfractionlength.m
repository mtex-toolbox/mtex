function l = subfractionlength(grains)
% returns the length of subfractions within a grain
%
%% Input
%  grains   - @grain
%
%% Output
%  l - length
%


b = find(hassubfraction(grains));
frs = [grains(b).subfractions];
 
l = zeros(size(grains));

for k=1:length(b)
	l(b(k)) = sum(diff(frs(k).xx).^2 + diff(frs(k).yy).^2);
end