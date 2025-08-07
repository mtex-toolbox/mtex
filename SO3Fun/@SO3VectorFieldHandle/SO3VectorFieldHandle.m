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

% The SO3TangentField objects have a inner tangent space representation.
% Hence they are constructed and stored with respect to this.
% Nevertheless, we can use the (ordinary) tangentSpace property to
% determine which representation we want the evaluations to have. Hence if
% we evaluate a SO3Vectorfield in some rotation, we obtain a tangent vector
% w.r.t. the inner tangent space representation. Afterwards MTEX converts
% this tangent vector to the desired representation, which is described by 
% the property tangentSpace.
% 
% Since for vector fields one of the symmmetries dissapear (dependent on 
% the tangent space representation), we introduce 2 hidden symmetry 
% properties for the initial symmetries, to describe the symmetries of the 
% SO3VectorFields properly.
% Note that the symmetries of the inner SO3Fun depends on the inner tangent
% space representation, while the symmetries of the vector field depends on
% the outer tangent space representation.
%

properties (Hidden = true)
  internTangentSpace SO3TangentSpace = SO3TangentSpace.leftVector;
  hiddenCS symmetry = crystalSymmetry;
  hiddenSS symmetry = specimenSymmetry;
end
  
methods
  function SO3VF = SO3VectorFieldHandle(fun,varargin)
    
    if isa(fun,'SO3VectorField')
      SO3VF.fun = @(rot) fun.eval(rot);
      SO3VF.internTangentSpace = fun.tangentSpace;
      SO3VF.tangentSpace = SO3TangentSpace.extract(varargin,fun.tangentSpace);
      SO3VF.hiddenCS = fun.hiddenCS;
      SO3VF.hiddenSS = fun.hiddenSS;
      return
    end
    
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
