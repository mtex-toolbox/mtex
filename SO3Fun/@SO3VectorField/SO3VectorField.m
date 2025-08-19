classdef SO3VectorField
% a class representing a vector field on the rotation group

% properties
%   SLeft = specimenSymmetry  % symmetry that acts from the left
% end

properties (Abstract = true)
  SRight % symmetry that acts from the right
  SLeft % symmetry that acts from the left
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
  hiddenCS symmetry
  hiddenSS symmetry
end


properties (Dependent = true)
  CS
  SS
end

methods

  function CS = get.CS(SO3VF)
    CS = SO3VF.SRight;
  end
  
  function SS = get.SS(SO3VF)
    SS = SO3VF.SLeft;
  end
  
  function SO3VF = set.CS(SO3VF,CS)
    SO3VF.SRight = CS;
  end
  
  function SO3VF = set.SS(SO3VF,SS)
    SO3VF.SLeft = SS;
  end
 
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
