function value = get(obj,vname)
% get object variable

if any(strcmp(fields(obj),vname))
  value = [obj.(vname)];
else
  switch vname
    case 'resolution'
      k = [obj.psi];
      hw = get(k,'halfwidth');
      value = min(hw);
    otherwise
      error('Unknown field in class ODF!')
  end
end
