function obj = set(obj,vname,value)
% set object variable to value

if strcmp(vname,'CS')
  
  if value ~= obj.CS
    % recompute representation in cartesian coordinates
    [h,k,l] = v2m(obj);
    obj.CS = value;
    obj.vector3d = m2v(h,k,l,value);
  end
  
else
  
  error('Unknown Field!');
  
end

