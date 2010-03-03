function obj = set(obj,vname,value,varargin)
% set object variable to value

if isa(vname,'CS') && ...
    check_option(varargin,'keepEuler')
    
  %%TODO
  
  [a,b,g] = get(obj,'Euler');

  obj.CS =  value;
  
  obj.quaternion = euler2quat(a,b,g,value);
   
else
  if iscell(value), value = value{1}; end
  obj.(vname) = value;
end


