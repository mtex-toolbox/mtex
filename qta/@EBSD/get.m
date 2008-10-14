function value = get(obj,vname)
% get object variable

if any(strcmp(fields(obj),vname))
  value = obj.(vname);
else
  switch vname
    case 'data'
      value = obj.orientations;
    case 'x'
      value = obj.xy(:,1);
    case 'y'
      value = obj.xy(:,2);
    otherwise
      error('Unknown field in class EBSD!')
  end
end
