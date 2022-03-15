classdef SO3FunHandle < SO3Fun
% a class represeneting a function on the rotation group
  
properties
  fun
  antipodal = false
  SLeft  = specimenSymmetry
  SRight = specimenSymmetry
  bandwidth = 96
end

methods
  function SO3F = SO3FunHandle(fun,varargin)
    
    SO3F.fun = fun;

    [SRight,SLeft] = extractSym(varargin);
    SO3F.SRight = SRight;
    SO3F.SLeft = SLeft;
    
  end
  
  function f = eval(SO3F,rot,varargin)
    f = reshape(SO3F.fun(rot),size(rot));
  end  
  
end


methods (Static = true)
   
    
end


end
