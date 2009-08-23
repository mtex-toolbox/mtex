function d = double(G)
% convert to double

points = {G.points};
dim = 1 + (sum(cellfun('size', points, 2)) > numel(points));
d = cat(dim,points{:});

%since some functions wants it as (1xn)
if dim == 1,  d = reshape(d,1,[]); end 
