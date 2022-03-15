classdef SO3VectorFieldHandle < SO3VectorField
% a class represeneting a vector field on SO(3)
  
properties
  fun
  antipodal = false
  SLeft  = specimenSymmetry
  SRight = specimenSymmetry
end
  
methods
  function SO3VF = SO3VectorFieldHandle(fun,varargin)
    
    SO3VF.fun = fun;
    
    [SRight,SLeft] = extractSym(varargin);
    SO3VF.SRight = SRight;
    SO3VF.SLeft = SLeft;
    
  end
  
  function f = eval(SO3VF,ori,varargin)
    f = SO3VF.fun(ori);
  end
  
end

end
