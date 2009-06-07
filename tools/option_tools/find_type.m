function pos = find_type(varargin,type)
%parse arguments list for a specific type an returns the first occurance

pos = find(cellfun('isclass',varargin,type),1,'first');