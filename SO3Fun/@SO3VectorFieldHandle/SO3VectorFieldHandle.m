classdef (InferiorClasses = {?SO3FunBingham,?SO3FunCBF,?SO3FunComposition, ...
    ?SO3FunHandle,?SO3FunHarmonic,?SO3FunHomochoric,?SO3FunRBF,?SO3FunSBF})...
    SO3VectorFieldHandle < SO3VectorField
% a class representing a vector field on SO(3)
  
properties
  fun
  SLeft  = specimenSymmetry.default
  SRight = specimenSymmetry.default
  bandwidth = getMTEXpref('maxSO3Bandwidth');
  tangentSpace = SO3TangentSpace.leftVector
end
  
properties (Dependent = true)
  isReal
end


methods
  function SO3VF = SO3VectorFieldHandle(fun,varargin)
    
    SO3VF.fun = fun;
    
    [SRight,SLeft] = extractSym(varargin);
    SO3VF.SRight = SRight;
    SO3VF.SLeft = SLeft;
    
    SO3VF.tangentSpace = SO3TangentSpace.extract(varargin{:});
    
  end

  function out = get.isReal(f)
    rot = rotation.rand(10);
    out = isreal(f.eval(rot));
  end

  function F = set.isReal(F,value)
    if ~value, return; end
    F = SO3VectorFieldHandle(@(rot) real(F.eval(rot)),F.CS,F.SS,F.tangentSpace);
  end
  
end

methods(Static = true)
  SO3VF = example(varargin)
end

end
