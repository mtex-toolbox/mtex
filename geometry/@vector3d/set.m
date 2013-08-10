function obj = set(obj,varargin)
% set object variable

switch varargin{1}
  case fields(obj)
    obj.(varargin{1}) = varargin{2};
  otherwise
    obj = set@dynOption(obj,varargin{:});
end

