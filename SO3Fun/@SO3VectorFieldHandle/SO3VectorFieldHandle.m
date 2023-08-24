classdef (InferiorClasses = {?SO3FunBingham,?SO3FunCBF,?SO3FunComposition, ...
    ?SO3FunHandle,?SO3FunHarmonic,?SO3FunHomochoric,?SO3FunRBF,?SO3FunSBF})...
    SO3VectorFieldHandle < SO3VectorField
% a class representing a vector field on SO(3)
  
properties
  fun
  SLeft  = specimenSymmetry
  SRight = specimenSymmetry
  bandwidth = getMTEXpref('maxSO3Bandwidth');
  tangentSpace = 'left'
end
  
methods
  function SO3VF = SO3VectorFieldHandle(fun,varargin)
    
    SO3VF.fun = fun;
    
    [SRight,SLeft] = extractSym(varargin);
    SO3VF.SRight = SRight;
    SO3VF.SLeft = SLeft;
    if check_option(varargin,'right')
      SO3VF.tangentSpace = 'right';
    end
    
  end
  
  function SO3VF = set.tangentSpace(SO3VF,s)
    if strcmp(s,'left') || strcmp(s,'right')
      SO3VF.tangentSpace = s;
    end
  end
  
end

end
