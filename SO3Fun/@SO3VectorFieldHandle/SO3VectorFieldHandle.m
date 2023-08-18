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
  
  function f = eval(SO3VF,ori,varargin)

    % change evaluation method to quadratureSO3Grid/eval
    if isa(ori,'quadratureSO3Grid')
      f = eval(SO3VF,ori,varargin);
    else
      % if isa(ori,'orientation')
      % ensureCompatibleSymmetries(SO3VF,ori)
      % end
      f = SO3VF.fun(ori);
    end

    % Make output right/left deendent from the input flag
    f = SO3TangentVector(f,SO3VF.tangentSpace);
    if check_option(varargin,'right')
      f = right(f,ori);
    end
    if check_option(varargin,'left')
      f = left(f,ori);
    end
    
  end

  function SO3VF = set.tangentSpace(SO3VF,s)
    if strcmp(s,'left') || strcmp(s,'right')
      SO3VF.tangentSpace = s;
    end
  end
  
end

end
