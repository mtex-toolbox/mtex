function criterion = gbc_custom(~,~,Dl,Dr,delta,varargin)
% blue print for a self defined grain boundary criterion
% check whether the two ebsd measurements are seperated by a grain boundary

% get the custom property
custom = get_option(varargin,'custom');

% get the threshold
delta = get_option(varargin,{'delta','threshold'}, delta);

% default threshold
if length(delta)>1, delta = 0.5; end

if isa(custom,'vector3d') || isa(custom,'quaternion') 
   criterion = angle(custom(Dl),custom(Dr)) < delta;
else
   criterion = abs(custom(Dl)-custom(Dr)) < delta;
end

