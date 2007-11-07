function fitcaxis
% scale all subfigures accordingly

ax = findall(gcf,'type','axes');
for i = 1:length(ax)
	c(i,:) = caxis(ax(i));
end
mi = min(c,[],1);
ma = max(c,[],1);
for i = 1:length(ax)
	caxis(ax(i),[mi(1),ma(2)]);
end
