classdef (InferiorClasses = {?SO3FunBingham,?SO3FunCBF,?SO3FunComposition, ...
    ?SO3FunHandle,?SO3FunHarmonic,?SO3FunHomochoric,?SO3FunRBF,?SO3FunSBF, ...
    ?SO3VectorFieldHandle,?vector3d}) ...
    SO3VectorFieldRBF < SO3VectorField
% a class representing a vector field on SO(3) by radial basis functions
%
% The three components of the tangent vector are stored as a 3x1 array of
% @SO3FunRBF, which keeps the field local - useful when it is fitted to
% scattered data such as a measured gradient.
%
% Syntax
%   SO3VF = SO3VectorFieldRBF(SO3F)
%   SO3VF = SO3VectorFieldRBF(fun)
%
% Input
%  SO3F - 3x1 @SO3FunRBF, the x, y and z component
%  fun  - @SO3VectorField or @function_handle to be approximated
%
% Output
%  SO3VF - @SO3VectorFieldRBF
%
% Options
%  SO3TangentSpace - the tangent space the values refer to
%
% Class Properties
%  SO3F         - the three components as @SO3FunRBF
%  x, y, z      - the individual components
%  bandwidth    - maximum harmonic degree
%  tangentSpace - @SO3TangentSpace of the evaluations
%  frameA, CS   - the frame acting from the right, the crystal side
%  frameB, SS   - the frame acting from the left, the specimen side
%
% See also
% SO3VectorField SO3FunRBF SO3TangentSpace

properties
  SO3F
  tangentSpace = SO3TangentSpace.leftVector
end

properties(Dependent = true)
  frameA
  frameB
  bandwidth
  x
  y
  z
  isReal
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

methods

  function SO3VF = SO3VectorFieldRBF(SO3F, varargin)
    % initialize a rotational vector field
    
    if nargin == 0, return; end

    if ~isa(SO3F,'SO3FunRBF')
      SO3VF = SO3VectorFieldRBF.approximate(SO3F,varargin{:});
      return
    end

    % SO3F should only have one symmetry. The other is hidden
    if SO3F.CS.id>1 && SO3F.SS.id>1
      warning(['The intern SO3FunRBF should only have one symmetry, ' ...
        'since the second symmetry acts as outer symmetry on the vector field.'])
    end

    % extract tangent space representation
    tS = SO3TangentSpace.extract(varargin);
    SO3VF.internTangentSpace = tS;
    SO3VF.tangentSpace = tS;

    % get symmetries - absence is empty, never a fabricated default, so a
    % passed triclinic symmetry survives with its frame (ADR 0003)
    [cs,ss] = extractSym(varargin,'empty');
    if isempty(cs), cs = SO3F.frameA; end
    if isempty(ss), ss = SO3F.frameB; end

    % set the symmetries (one of the symmetries have to be ignored,
    % dependent on the intern tangent space representation)
    SO3VF.hiddenCS = cs;
    SO3VF.hiddenSS = ss;
    if tS.isLeft
      SO3F.frameA = cs;
      SO3F.frameB = stripSym(ss);
    else
      SO3F.frameA = stripSym(cs);
      SO3F.frameB = ss;
    end

    % extract SO3Fun-structure
    SO3VF.SO3F = SO3F(:);
   
  end

  % -----------------------------------------------------------------------


  % Get and Set outer symmetries dependent of the tangent space representation
  function SO3VF = set.frameA(SO3VF,frameA)
    if sign(SO3VF.tangentSpace)<0
      error('The right symmetry may not be changed as long as the tangential space representation is on the left.')
    end
    SO3VF.hiddenCS = frameA;
    if sign(SO3VF.internTangentSpace)>0
      SO3VF.SO3F.CS = frameA;
    end
  end
  function SO3VF = set.frameB(SO3VF,frameB)
    if sign(SO3VF.tangentSpace)>0
      error('The left symmetry may not be changed as long as the tangential space representation is on the right.')
    end
    SO3VF.hiddenSS = frameB;
    if sign(SO3VF.internTangentSpace)<0
      SO3VF.SO3F.SS = frameB;
    end
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

  % -----------------------------------------------------------------------

  function check_symmetry(SO3VF)
    % check whether the symmetries of the inner SO3Fun are suitable to the 
    % symmetries of the vector field w.r.t. the tangent space
    % representations
    % strict: an equal valued fork is a different symmetry, see symFits
    if sign(SO3VF.internTangentSpace)>0
      E(1) = symFits(SO3VF.SO3F.CS,SO3VF.hiddenCS,'strict');
      E(2) = SO3VF.SO3F.SS.id == 1;
    else
      E(1) = SO3VF.SO3F.CS.id == 1;
      E(2) = symFits(SO3VF.SO3F.SS,SO3VF.hiddenSS,'strict');
    end
    if ~all(E)
      error(['The symmetries of the underlying SO3Fun do not match to the ' ...
        'hidden symmetries of the SO3VectorField and the innerTangentSpace representation.']);
    end
  end


  % -----------------------------------------------------------------------
  

  function bw = get.bandwidth(SO3VF), bw = SO3VF.SO3F.bandwidth; end
  function SO3VF = set.bandwidth(SO3VF,bw), SO3VF.SO3F.bandwidth = bw; end
  
  function r = get.isReal(SO3VF), r = SO3VF.SO3F.isReal; end  
  function SO3VF = set.isReal(SO3VF,r), SO3VF.SO3F.isReal = r; end

  function x = get.x(SO3VF), x = SO3VF.SO3F(1); end
  function y = get.y(SO3VF), y = SO3VF.SO3F(2); end
  function z = get.z(SO3VF), z = SO3VF.SO3F(3); end
  function SO3VF = set.x(SO3VF, x), SO3VF.SO3F(1) = x; end
  function SO3VF = set.y(SO3VF, y), SO3VF.SO3F(2) = y; end
  function SO3VF = set.z(SO3VF, z), SO3VF.SO3F(3) = z; end
  
end

methods(Static = true)
  SO3VF = approximate(f, varargin)
  SO3VF = interpolate(nodes, values, varargin)
  SO3VF = example(varargin)
end

end
