classdef (InferiorClasses = {?SO3FunBingham,?SO3FunCBF,?SO3FunComposition, ...
    ?SO3FunHandle,?SO3FunHarmonic,?SO3FunHomochoric,?SO3FunRBF,?SO3FunSBF})...
    SO3VectorFieldHandle < SO3VectorField
% a class representing a vector field on SO(3)
  
properties
  fun
  bandwidth = getMTEXpref('maxSO3Bandwidth');
  tangentSpace = SO3TangentSpace.leftVector
end

properties (Dependent = true)
  SLeft
  SRight
end

properties (Hidden = true)
  internTangentSpace SO3TangentSpace = SO3TangentSpace.leftVector;
  hiddenCS symmetry = specimenSymmetry;
  hiddenSS symmetry = specimenSymmetry;
end
  
methods
  function SO3VF = SO3VectorFieldHandle(fun,varargin)
    
    SO3VF.fun = fun;
    
    % set symmetries
    [SRight,SLeft] = extractSym(varargin);
    SO3VF.hiddenCS = SRight;
    SO3VF.hiddenSS = SLeft;
    
    % extract tangent space representation
    tS = SO3TangentSpace.extract(varargin);
    SO3VF.internTangentSpace = tS;
    SO3VF.tangentSpace = tS;

  end
  
  % -----------------------------------------------------------------------

  % Get and Set outer symmetries dependent of the tangent space representation
  function SO3VF = set.SRight(SO3VF,SRight)
    if sign(SO3VF.tangentSpace)<0
      error('The right symmetry may not be changed as long as the tangential space representation is on the left.')
    end
    SO3VF.hiddenCS = SRight;
  end
  function SO3VF = set.SLeft(SO3VF,SLeft)
    if sign(SO3VF.tangentSpace)>0
      error('The left symmetry may not be changed as long as the tangential space representation is on the right.')
    end
    SO3VF.hiddenSS = SLeft;
  end
  function cs = get.SRight(SO3VF)
    if sign(SO3VF.tangentSpace)>0
      cs = SO3VF.hiddenCS;
    else
      cs = ID1(SO3VF.hiddenCS);
    end
  end
  function ss = get.SLeft(SO3VF)
    if sign(SO3VF.tangentSpace)>0
      ss = ID1(SO3VF.hiddenSS);
    else
      ss = SO3VF.hiddenSS;
    end
  end

  % -----------------------------------------------------------------------

end

end
