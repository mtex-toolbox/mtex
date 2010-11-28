function obj = set(obj,vname,value)
% set object variable

switch vname
  case fields(obj)
    obj.(vname) = value;
  otherwise
    error('Unknown field in class S2Grid!')
end

