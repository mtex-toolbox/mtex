function rgb = ind2color(ind,varargin)
% convert ind to rgb values

cmap = getMTEXpref('colors');

if check_option(varargin,'ordered')
  order = [1,6,19,12,20,22,3,11,18,16,...
    23,8,7,2,14,15,9,4,21,5,24,13,10,17];
  cmap = cmap(order,:);
end


rgb = cmap(ind,:);