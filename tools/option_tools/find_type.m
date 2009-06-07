function pos = find_type(varargin,type)
%parse arguments list for a specific type an returns the first occurance

pos = find(cellfun(@(x) isa(x,type),varargin),1,'first');
