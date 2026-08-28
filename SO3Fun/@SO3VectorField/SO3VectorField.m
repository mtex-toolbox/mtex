classdef SO3VectorField
% an abstract class representing vector fields on the rotation group
%
% A vector field on SO(3) assigns a tangent vector to every orientation,
% e.g. the gradient of an ODF. Tangent vectors live in either the left or
% the right tangent space, see @SO3TangentSpace; the property tangentSpace
% says which representation evaluations are returned in.
%
% Deriving classes only have to implement the method eval.
%
% Class Properties
%  frameA       - @referenceFrame of the crystal side, acting from the right
%  frameB       - @referenceFrame of the specimen side, acting from the left
%  SRight, CS   - the frame of the crystal side, positionally A
%  SLeft, SS    - the frame of the specimen side, positionally B
%  tangentSpace - @SO3TangentSpace of the evaluations
%
% Derived Classes
%  @SO3VectorFieldHarmonic - harmonic series of the components
%  @SO3VectorFieldRBF      - radial basis function series
%  @SO3VectorFieldHandle   - field given by a function handle
%
% See also
% SO3Fun SO3TangentSpace SO3TangentVector

properties (Abstract = true)
  frameA % the frame the argument is given in, acting from the right
  frameB % the frame the argument maps into, acting from the left
  tangentSpace SO3TangentSpace % classify whether left or right sided tangent space is asumed in evaluation
end

% The SO3VectorField objects have a inner tangent space representation.
% Hence they are constructed and stored with respect to this.
% Nevertheless, we can use the (ordinary) tangentSpace property to
% determine which representation we want the evaluations to have. Hence if
% we evaluate a SO3VectorField in some rotation, we obtain a tangent vector
% w.r.t. the inner tangent space representation. Afterwards MTEX converts
% this tangent vector to the desired representation, which is described by 
% the property tangentSpace.
% 
% Since for vector fields one of the symmetries disappear (dependent on 
% the tangent space representation), we introduce 2 hidden symmetry 
% properties for the initial symmetries, to describe the symmetries of the 
% SO3VectorFields properly.
% Note that the symmetries of the inner SO3Fun depends on the inner tangent
% space representation, while the symmetries of the vector field depends on
% the outer tangent space representation.
%

properties (Abstract = true,Hidden = true)
  internTangentSpace SO3TangentSpace % classify whether left or right sided tangent space is used by definition of the object
  hiddenCS referenceFrame
  hiddenSS referenceFrame
end


properties (Dependent = true)
  CS     % the frame of the crystal side - positionally A, see frameA
  SS     % the frame of the specimen side - positionally B, see frameB
  SRight % the frame acting from the right, which is A
  SLeft  % the frame acting from the left, which is B
end

methods

  % the four older names resolve positionally, as on SO3Fun
  function fr = get.CS(SO3VF), fr = SO3VF.frameA; end
  function fr = get.SS(SO3VF), fr = SO3VF.frameB; end
  function fr = get.SRight(SO3VF), fr = SO3VF.frameA; end
  function fr = get.SLeft(SO3VF), fr = SO3VF.frameB; end

  function SO3VF = set.CS(SO3VF,fr), SO3VF.frameA = fr; end
  function SO3VF = set.SS(SO3VF,fr), SO3VF.frameB = fr; end
  function SO3VF = set.SRight(SO3VF,fr), SO3VF.frameA = fr; end
  function SO3VF = set.SLeft(SO3VF,fr), SO3VF.frameB = fr; end

end

methods (Hidden = true)
  function str = symChar(SO3VF)
    %str = [char(SO3VF.CS,'compact') ' ' char([55358 56342]) ' ' char(SO3VF.SS,'compact')];
    str = [char(SO3VF.CS,'compact') ' ' char(8594) ' ' char(SO3VF.SS,'compact')];
  end
end

methods (Abstract = true)

  f = eval(F, v, varargin)

end

methods (Sealed = true)
  h = plot(F,varargin)
    
end

methods(Static = true)
  
  function SO3VF = X(varargin)
    SO3VF = SO3VectorFieldHandle(@(varargin) vector3d.X(size(varargin{1})),varargin{:});
  end
  
  function SO3VF = Y(varargin)
    SO3VF = SO3VectorFieldHandle(@(varargin) vector3d.Y(size(varargin{1})),varargin{:});
  end
  
  function SO3VF = Z(varargin)
    SO3VF = SO3VectorFieldHandle(@(varargin) vector3d.Z(size(varargin{1})),varargin{:});
  end

end

end
