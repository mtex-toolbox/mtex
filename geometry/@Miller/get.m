function value = get(obj,vname)
% get object variable

switch lower(vname)

  case {'h','k','l','i'}
   
    [h,k,l] = v2m(obj);
    
    switch lower(vname)
      
      case 'h'
        value = h;
      case 'k'
        value = k;
      case 'l'
        value = l;
      case 'i'
        if any(strcmp(Laue(obj.CS),{'-3m','-3','6/m','6/mmm'}))
          value = -h - k;
        else
          value = [];
        end
    end
    
  otherwise
    
    value = obj.(vname);
    
end
