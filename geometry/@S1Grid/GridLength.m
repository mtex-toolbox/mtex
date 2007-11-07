function l = GridLength(G)
% return number of points

l = zeros(1,length(G));
for i = 1:length(G)
	l(i) = length(G(i).points);
end
