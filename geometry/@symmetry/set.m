function obj = set(obj,vname,value)
% set object variable to value

if ~strcmp(vname,'color'), error('check this!');end

obj.(vname) = value;
