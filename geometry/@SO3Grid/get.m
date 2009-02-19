function value = get(obj,vname)
% get object variable

switch vname
  case {'CS','SS'}
    value = obj(1).(vname);
  case fields(obj)
    value = [obj.(vname)];
  otherwise
    error('Unknown field in class ODF!')
end

