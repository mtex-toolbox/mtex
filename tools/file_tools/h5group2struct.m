function props = h5group2struct(fname,group)
% read h5 group to struct

props = struct;

for item = group.Datasets.'
  if length(item.ChunkSize) > 1, continue; end
  data = double(h5read(fname,[group.Name '/' item.Name]));
  name = strrep(item.Name,' ','_');
  props.(name) = data;
end

end
