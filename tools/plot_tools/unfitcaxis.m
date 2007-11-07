function unfitcaxis
% set axis in a plot to auto

ax = get(gcf,'Children');
for i = 1:length(ax)
	caxis(ax(i),'auto');
end
