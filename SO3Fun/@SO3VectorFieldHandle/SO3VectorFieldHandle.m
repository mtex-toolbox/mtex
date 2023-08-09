classdef (InferiorClasses = {?SO3FunBingham,?SO3FunCBF,?SO3FunComposition, ...
    ?SO3FunHandle,?SO3FunHarmonic,?SO3FunHomochoric,?SO3FunRBF,?SO3FunSBF})...
    SO3VectorFieldHandle < SO3VectorField
% a class representing a vector field on SO(3)
  
properties
  fun
  antipodal = false
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
%     if isa(ori,'orientation')
%       ensureCompatibleSymmetries(SO3VF,ori)
%     end
      f = SO3VF.fun(ori);
    end

    if check_option(varargin,'right') && strcmp(SO3VF.tangentSpace,'left')
      % make left sided to right sided tangent vectors
      f = inv(ori).*f;
      f.opt.tangentSpace = 'right';
    elseif check_option(varargin,'left') && strcmp(SO3VF.tangentSpace,'right')
      % make right sided to left sided tangent vectors
      f = ori.*f;
      f.opt.tangentSpace = 'left';
    else
      f.opt.tangentSpace = SO3VF.tangentSpace;
    end
    
  end

  function SO3VF = set.tangentSpace(SO3VF,s)
    if strcmp(s,'left') || strcmp(s,'right')
      SO3VF.tangentSpace=s;
    end
  end
  
end

end
