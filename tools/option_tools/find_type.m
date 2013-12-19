function pos = find_type(varargin,type,all)
%parse arguments list for a specific type an returns the first occurance


pos = find(cellfun('isclass',varargin,type));

if isempty(pos) || (nargin > 2 && all)
  return
else
  pos = pos(1);
end
