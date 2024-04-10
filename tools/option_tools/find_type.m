function pos = find_type(argList,type,all)
% parse arguments list for a specific type an returns the first occurrence

pos = find(cellfun('isclass',argList,type));

if isempty(pos) || (nargin > 2 && all)
  return
else
  pos = pos(1);
end
