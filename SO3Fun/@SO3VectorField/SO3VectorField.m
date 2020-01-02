classdef SO3VectorField
% a class represeneting a vector field on the sphere

properties (Abstract = true)
  SLeft  % symmetry that acts from the left
  SRight % symmetry that acts from the right
end

properties (Dependent = true)
  CS
  SS
end

methods

  function CS = get.CS(SO3F)
    CS = SO3F.SRight;
  end
  
  function SS = get.SS(SO3F)
    SS = SO3F.SLeft;
  end
  
  function SO3F = set.CS(SO3F,CS)
    SO3F.SRight = CS;
  end
  
  function SO3F = set.SS(SO3F,SS)
    SO3F.SLeft = SS;
  end
  
end

methods (Abstract = true)

  f = eval(sF, v, varargin)

end

methods (Sealed = true)
  h = plot(sF,varargin)
    
end

methods(Static = true)
  
  function SO3VF = X(varargin)
    
    SO3VF = SO3VectorFieldHandle(@(varargin) vector3d.X,varargin{:});
    
  end
  
  function SO3VF = Y(varargin)
    
    SO3VF = SO3VectorFieldHandle(@(varargin) vector3d.Y,varargin{:});
    
  end
  
  function SO3VF = Z(varargin)
    
    SO3VF = SO3VectorFieldHandle(@(varargin) vector3d.Z,varargin{:});
    
  end 
  
end

end
