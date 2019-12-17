function criterion = gbc_custom(ori,CS,Dl,Dr,delta,varargin)
% blue print for a self defined grain boundary criterion

% check whether the two ebsd measurements are seperated by a grain boundary
custom = get_option(varargin,'custom');
delta = get_option(varargin,'delta',delta);
if isa(custom,'vector3d')
   criterion = angle(custom(Dl),custom(Dr)) < delta;
else
   criterion = abs(custom(Dl)-custom(Dr)) < delta;
end

