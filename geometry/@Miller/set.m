function obj = set(obj,vname,value,varargin)
% set object variable to value

if strcmp(vname,'CS')
  
  if value ~= obj.CS
    % recompute representation in cartesian coordinates
    if check_option(obj,'uvw')
      uvw = v2d(obj);
      obj.CS = value;
      obj.vector3d = reshape(d2v(uvw(:,1),uvw(:,2),uvw(:,end),value),size(obj));
      obj = set_option(obj,'uvw');
    else
      hkl = v2m(obj);
      obj.CS = value;
      obj.vector3d = reshape(m2v(hkl(:,1),hkl(:,2),hkl(:,end),value),size(obj));
    end
  end
  
else
  error('Unknown Field!');
end
