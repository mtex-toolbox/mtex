function l = GridLength(G)
% return number of points

l = zeros(1,length(G));
for i = 1:length(G)
	l(i) = numel(G(i).points);
end
%l = arrayfun(@(x) numel(x.points),struct(G));
%l = reshape(l,1,[]);
