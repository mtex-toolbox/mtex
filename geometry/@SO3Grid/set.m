function obj = set(obj,vname,value,varargin)
% set object variable to value

if isfield(obj,vname)
  obj.(vname) = value{1};
else
  obj = set@rotation(obj,vname,value,varargin{:});
end
