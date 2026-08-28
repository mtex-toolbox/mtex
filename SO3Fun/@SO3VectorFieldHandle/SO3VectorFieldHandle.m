classdef (InferiorClasses = {?SO3FunBingham,?SO3FunCBF,?SO3FunComposition, ...
    ?SO3FunHandle,?SO3FunHarmonic,?SO3FunHomochoric,?SO3FunRBF,?SO3FunSBF})...
    SO3VectorFieldHandle < SO3VectorField
% a class representing a vector field on SO(3) by a function handle
%
% Syntax
%   SO3VF = SO3VectorFieldHandle(fun)
%   SO3VF = SO3VectorFieldHandle(fun,CS,SS)
%   SO3VF = SO3VectorFieldHandle(fun,CS,SS,SO3TangentSpace.rightVector)
%
% Input
%  fun   - @function_handle taking a @rotation and returning a @vector3d
%  CS,SS - @symmetry
%
% Output
%  SO3VF - @SO3VectorFieldHandle
%
% Options
%  SO3TangentSpace - the tangent space the values refer to
%
% Class Properties
%  fun          - @function_handle
%  bandwidth    - degree used when converting to @SO3VectorFieldHarmonic
%  tangentSpace - @SO3TangentSpace of the evaluations
%  frameA, CS   - the frame acting from the right, the crystal side
%  frameB, SS   - the frame acting from the left, the specimen side
%
% Example
%
%   SO3VF = SO3VectorFieldHandle(@(rot) rot.axis)
%
% See also
% SO3VectorField SO3VectorFieldHarmonic

properties
  fun
  bandwidth = getMTEXpref('maxSO3Bandwidth');
  tangentSpace = SO3TangentSpace.leftVector
end

properties (Dependent = true)
  frameB
  frameA
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
  hiddenCS referenceFrame = crystalFrame;
  hiddenSS referenceFrame = specimenFrame.default;
end
properties (Dependent = true)
  isReal
end

methods
  function SO3VF = SO3VectorFieldHandle(fun,varargin)
    
    if isa(fun,'SO3VectorField')
      % (When there are multiple concatenations, we try to prevent the tangential space from switching back and forth repeatedly.)
      tS = fun.tangentSpace;
      fun.tangentSpace = fun.internTangentSpace;
      SO3VF.fun = @(rot) fun.eval(rot);
      SO3VF.internTangentSpace = fun.internTangentSpace;
      SO3VF.tangentSpace = SO3TangentSpace.extract(varargin,tS);
      SO3VF.hiddenCS = fun.hiddenCS;
      SO3VF.hiddenSS = fun.hiddenSS;
      return
    end
    
    SO3VF.fun = fun;
    
    % set symmetries - a bare function handle has nothing to inherit from,
    % so an absent symmetry genuinely means the session default
    [frameA,frameB] = extractSym(varargin,'empty');
    if isempty(frameA), frameA = specimenSymmetry; end
    if isempty(frameB), frameB = specimenSymmetry; end
    SO3VF.hiddenCS = frameA;
    SO3VF.hiddenSS = frameB;
    
    % extract tangent space representation
    tS = SO3TangentSpace.extract(varargin);
    SO3VF.internTangentSpace = tS;
    SO3VF.tangentSpace = tS;

  end
  
  % -----------------------------------------------------------------------

  % Get and Set outer symmetries dependent of the tangent space representation
  function SO3VF = set.frameA(SO3VF,frameA)
    if sign(SO3VF.tangentSpace)<0
      error('The right symmetry may not be changed as long as the tangential space representation is on the left.')
    end
    SO3VF.hiddenCS = frameA;
  end
  function SO3VF = set.frameB(SO3VF,frameB)
    if sign(SO3VF.tangentSpace)>0
      error('The left symmetry may not be changed as long as the tangential space representation is on the right.')
    end
    SO3VF.hiddenSS = frameB;
  end
  function cs = get.frameA(SO3VF)
    if sign(SO3VF.tangentSpace)>0
      cs = SO3VF.hiddenCS;
    else
      cs = stripSym(SO3VF.hiddenCS);
    end
  end
  function ss = get.frameB(SO3VF)
    if sign(SO3VF.tangentSpace)>0
      ss = stripSym(SO3VF.hiddenSS);
    else
      ss = SO3VF.hiddenSS;
    end
  end
  function out = get.isReal(f)
    rot = rotation.rand(10);
    out = isreal(f.eval(rot));
  end

  function F = set.isReal(F,value)
    if ~value, return; end
    F = SO3VectorFieldHandle(@(rot) real(F.eval(rot)),F.hiddenCS,F.hiddenSS,F.tangentSpace);
  end

  % -----------------------------------------------------------------------

end

methods(Static = true)
  SO3VF = example(varargin)
end

end
