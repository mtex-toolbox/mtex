function value = get(obj,vname)
% get object variable

switch lower(vname)
  case {'cs','ss'}
    value = obj(1).(vname);
  case {'quaternion','grid','orientation'}
    value = quaternion(obj);    
  case fields(obj)
    value = [obj.(vname)];
  otherwise
    error('Unknown field in class ODF!')
end

