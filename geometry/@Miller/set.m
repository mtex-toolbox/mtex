function obj = set(obj,vname,value,varargin)
% set object variable to value

if strcmp(vname,'CS')
  
  if value ~= obj.CS
    
    % keep representation in displayStyle when changing crystal symmetry    
    switch obj.dispStyle
    
      case 'uvw'
    
        uvw = obj.uvw;
        obj.CS = value;
        obj.uvw = uvw;
        
      case 'hkl'
    
        hkl = obj.hkl;
        obj.CS = value;
        obj.hkl = hkl;
        
      otherwise
        
        obj.CS = value;
        
    end
  end
else
  
  obj = set@vector3d(obj,vname,value,varargin{:});
  
end
