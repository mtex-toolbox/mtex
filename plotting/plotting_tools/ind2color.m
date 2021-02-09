function rgb = ind2color(ind)
% convert ind to rgb values

cmap = getMTEXpref('colors');
rgb = cmap(ind,:);