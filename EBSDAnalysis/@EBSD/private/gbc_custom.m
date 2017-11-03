function criterion = gbc_custom(ori,CS,Dl,Dr,varargin)
% blue print for a self defined grain boundary criterion

% check whether the two ebsd measurements are seperated by a grain boundary
custom = get_option(varargin,'custom');
delta = get_option(varargin,'delta');
criterion = abs(custom(Dl)-custom(Dr)) < delta;
