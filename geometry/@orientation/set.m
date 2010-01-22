function obj = set(obj,vname,value,varargin)
% set object variable to value

if isa(vname,'CS') && ...
    check_option(varargin,'keepEuler')
    
  [a,b,g] = get(obj,'Euler');

  obj.CS =  value;
  
  obj.quaternion = euler2quat(a,b,g,value);
   
else
  obj.(vname) = value{1};
end


