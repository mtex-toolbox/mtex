function obj = set_option(obj,varargin)
% set object variable to value

for i = 1:numel(obj)    
  obj(i).options = set_option(obj(i).options,varargin{:});
end

