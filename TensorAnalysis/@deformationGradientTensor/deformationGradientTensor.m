classdef deformationGradientTensor < tensor
  % 
  % 
  % The deformation gradient F contains the full information about the
  % local rotation and deformation of the material. It also shows, for
  % example, how a small line segment in the undeformed body, dX, is
  % rotated and stretched into a line segment in the deformed body, dx,
  % since dx = F dX. As F is volume preserving this implies that det F = 1.
  
  methods
    function F = deformationGradientTensor(varargin)
      F = F@tensor(varargin{:},'rank',2);
    end       
  end

  methods (Static = true)
  
    F = pureShear(exp,compr,lambda)
    F = simpleShear(d,n,e)
    F = uniaxial(d,rate);
    
  end
  
  
end

