function obj = set(obj,vname,value)
% set object variable to value

if strcmp(vname,'CS')
  
  if value ~= obj.CS
    % recompute representation in cartesian coordinates
    if check_option(obj,'uvw')
      uvw = v2d(obj);
      obj.CS = value;
      obj.vector3d = reshape(m2v(uvw(:,1),uvw(:,2),uvw(:,3),value),size(obj));
    else
      hkl = v2m(obj);
      obj.CS = value;
      obj.vector3d = reshape(m2v(hkl(:,1),hkl(:,2),hkl(:,3),value),size(obj));
    end
  end
  
else
  error('Unknown Field!');
end
