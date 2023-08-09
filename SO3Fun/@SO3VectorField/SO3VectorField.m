classdef SO3VectorField
% a class representing a vector field on the rotation group

% properties
%   SLeft = specimenSymmetry  % symmetry that acts from the left
% end

properties (Abstract = true)
  SRight % symmetry that acts from the right
  SLeft % symmetry that acts from the left
  tangentSpace % classify whether left or right sided tangent space is used
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
