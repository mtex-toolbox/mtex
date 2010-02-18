function value = get(obj,vname)
% get object variable

switch vname
  case fields(obj)
    value = [obj.(vname)];
  case {'aufstellung','alignment'}
    
    if any(strcmpi(obj.laue,{'3m','-3m'}))
      if vector3d(Miller(1,0,0,obj)) == -yvector
        value = 2;
      else
        value = 1;
      end
    else
      value = 1;
    end
        
  otherwise
    error('Unknown field in class symmetry!')
end

