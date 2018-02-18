function [data,args] = extract_data(numData,args)
% extract data

if ~isempty(args) && ...
    (prod(size(args{1})) == numData || ...
    prod(size(args{1})) == 3 * numData) && ... % for rgb coloring
    (isnumeric(args{1}) || isa(args{1},'vector3d') ||...
    isa(args{1},'crystalShape')) %#ok<*PSIZE>
  data = args{1};
  data = reshape(data,numData,[]);
  args(1) = [];
else
  data = [];
end

end
