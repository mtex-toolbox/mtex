function value = get(obj,vname)
% get object variable

switch vname
  case {'resolution','res'}
    value = min([obj(1).res]);
  case fields(obj)
    value = [obj.(vname)];
  otherwise
    error('Unknown field in class S2Grid!')
end

