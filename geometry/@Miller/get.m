function value = get(obj,vname)
% get object variable

switch lower(vname)

  case {'hkl','h','k','l','i'}
 
    value = v2m(obj);
   
    switch lower(vname)
        
      case 'h', value = value(:,1);
      case 'k', value = value(:,2);
      case 'l', value = value(:,end);
      case 'i'
        if size(value,2) == 4
          value = value(:,3);
        else
          value = [];
        end
    end
  
  case {'uvw','u','v','w','t'}
    
    value = v2d(obj);
    
    switch lower(vname)
    
      case 'u', value = value(:,1);
      case 'v', value = value(:,2);
      case 'w', value = value(:,3);
      case 't'
        if size(value,2) == 4
          value = value(:,3);
        else
          value = [];
        end
        
    end
  otherwise
    
    value = obj.(vname);
    
end
