classdef SO3VectorField
% a class represeneting a vector field on the sphere

methods

end

methods (Abstract = true)

  f = eval(sF, v, varargin)

end

methods (Sealed = true)
  h = plot(sF,varargin)
    
end

methods(Static = true)
  
  function SO3VF = X(varargin)
    
    SO3VF = SO3VectorFieldHandle(@(varargin) vector3d.X);
    
  end
  
  function SO3VF = Y(varargin)
    
    SO3VF = SO3VectorFieldHandle(@(varargin) vector3d.Y);
    
  end
  
  function SO3VF = Z(varargin)
    
    SO3VF = SO3VectorFieldHandle(@(varargin) vector3d.Z);
    
  end 
  
end

end
