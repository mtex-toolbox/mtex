function d = getResolution(G)
% return resolution

d = zeros(1,length(G));
for i = 1:length(G)
	d(i) = min([2*pi,...
    reshape(abs(G(i).points(2:end)-G(i).points(1:end-1)),1,[])]);
end
