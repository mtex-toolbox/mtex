function obj = set(obj,vname,value)
% set object variable

switch vname
  case fields(obj)
    obj.(vname) = value;
  case fields(obj.vector3d)
    obj.vector3d = set(obj.vector3d,vname,value);
  otherwise
    error('Unknown field in class S2Grid!')
end

