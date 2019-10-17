function rgb = ind2color(ind)
% convert ind to rgb values

cmap = vega20;
rgb = cmap(ind,:);