function h = hashole(p)

% p.holes
p = polygon(p);
h = ~cellfun('isempty',{p.holes});