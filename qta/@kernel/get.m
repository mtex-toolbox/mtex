function value = get(obj,vname)
% get object variable

if any(strcmp(fields(obj),vname))
  value = [obj.(vname)];
else
  switch vname
    case {'hw','halfwidth'}
      value = [obj.hw];
    otherwise
      error('Unknown field in class kernel!')
  end
end
