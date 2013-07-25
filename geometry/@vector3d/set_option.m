function obj = set_option(obj,varargin)
% set object variable to value

obj.options = setOption(obj.options,varargin{:});

