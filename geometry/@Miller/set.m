function obj = set(obj,vname,value)
% set object variable to value

if strcmp(vname,'CS')
  
  if value ~= obj.CS
    % recompute representation in cartesian coordinates
    hkl = v2m(obj);
    obj.CS = value;
    obj.vector3d = m2v(hkl(:,1),hkl(:,2),hkl(:,3),value);
  end
  
else
  error('Unknown Field!');
end
