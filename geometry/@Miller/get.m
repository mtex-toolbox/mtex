function value = get(obj,vname)
% get object variable

switch lower(vname)

  case 'hkl'
    
    value = v2m(obj);
  
  case 'uvw'
    
    value = v2d(obj);    
    
  otherwise
    
    value = obj.(vname);
    
end
