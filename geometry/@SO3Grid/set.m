function obj = set(obj,vname,value,varargin)
% set object variable to value

if isfield(obj,vname)
  obj.(vname) = value{1};
else
  obj.orientation = set(obj.orientation,vname,value,varargin{:});
end
