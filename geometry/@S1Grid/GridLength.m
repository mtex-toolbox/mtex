function l = GridLength(G)
% return number of points

l = cellfun('prodofsize',{G.points});
