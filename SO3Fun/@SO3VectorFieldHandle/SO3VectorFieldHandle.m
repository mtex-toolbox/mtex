classdef (InferiorClasses = {?SO3FunHarmonic,?SO3FunBingham,?SO3FunCBF,?SO3FunComposition, ...
    ?SO3FunHandle,?SO3FunHomochoric,?SO3FunRBF}) SO3VectorFieldHandle < SO3VectorField
% a class representing a vector field on SO(3)
  
properties
  fun
  antipodal = false
  SLeft  = specimenSymmetry
  SRight = specimenSymmetry
  bandwidth = 96
end
  
methods
  function SO3VF = SO3VectorFieldHandle(fun,varargin)
    
    SO3VF.fun = fun;
    
    [SRight,SLeft] = extractSym(varargin);
    SO3VF.SRight = SRight;
    SO3VF.SLeft = SLeft;
    
  end
  
  function f = eval(SO3VF,ori,varargin)
%     if isa(ori,'orientation')
%       ensureCompatibleSymmetries(SO3VF,ori)
%     end

    f = SO3VF.fun(ori);
  end
  
end

end
