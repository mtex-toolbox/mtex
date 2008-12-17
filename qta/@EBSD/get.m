function value = get(obj,vname)
% get object variable

switch vname
  case {'comment','CS','SS','options'}
    value = obj(1).(vname);
  case fields(obj)
    value = [obj.(vname)];
  case 'data'
    value = obj.orientations;
  case 'x'
    value = obj.xy(:,1);
  case 'y'
    value = obj.xy(:,2);
  otherwise
    error('Unknown field in class EBSD!')
end

