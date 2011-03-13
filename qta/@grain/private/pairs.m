function pair = pairs(grains)
% return neighboured grains as a pair of its listposition

grain_ids = get(grains,'id');
grain_neighbours = get(grains,'neighbour');

cs = [ 0 ; cumsum(cellfun('prodofsize',grain_neighbours))];
pair = zeros(cs(end),2);
for l = 1:length(grain_ids)
  pair(cs(l)+1:cs(l+1),1) = l;
end

grain_neighbours = vertcat(grain_neighbours{:});
code = zeros(1,max(max(grain_ids),max(grain_neighbours)));
code(grain_ids) = 1:length(grain_ids);

pair(:,2) = code(grain_neighbours);
pair(any(pair == 0,2),:) = [];
