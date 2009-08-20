function d = double(G)
% convert to double
 
f = {G.points};
dim = 1 + (sum(cellfun('size', f, 2)) > length(f));
d = cat(dim,f{:});
if dim == 1,  d = reshape(d,1,[]); end

% for i = 1:length(G)
%   G(i).points = reshape(G(i).points,1,[]);
% end
% 
% d = [G.points];
