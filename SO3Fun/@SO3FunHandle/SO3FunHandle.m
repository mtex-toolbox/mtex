classdef SO3FunHandle < SO3Fun
% a class represeneting a function on the rotation group
  
properties
  fun
  antipodal = false
end


methods
  function SO3F = SO3FunHandle(fun,varargin)
    
    SO3F = SO3F@SO3Fun(varargin{:});
    SO3F.fun = fun;
  end
  
  function f = eval(SO3F,rot)
    f = SO3F.fun(rot);
  end
  
end


methods (Static = true)
   
    
end


end
