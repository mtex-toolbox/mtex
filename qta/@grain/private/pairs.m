function pair = pairs(grains)
% return neighboured grains as a pair of its listposition

grain_ids = vertcat(grains.id);
grain_neighbours = vertcat(grains.neighbour);
      
code = zeros(1,max([grain_ids; grain_neighbours]));
code(grain_ids) = 1:length(grain_ids);

cs = [ 0 cumsum(cellfun('length',{grains.neighbour}))];
pair = zeros(cs(end),2);
for l = 1:length(grain_ids)
  pair(cs(l)+1:cs(l+1),1) = l;
end

pair(:,2) = code(grain_neighbours);
pair(any(pair == 0,2),:) = [];