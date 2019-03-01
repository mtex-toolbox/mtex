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
    
    function F = simpleShear(d,n,e)
      % simple shear deformation tensor
      %
      % Syntax
      %   F = deformationGradientTensor.simpleShear(d,r)
      %
      % Input
      %  d - @vector3d shear direction
      %  n - @vector3d normal direction
      %  e - strain rate
      %
      % Output
      %  L - @velocityGradientTensor
      %           
    
      if nargin == 2, e = 1; end
      
      F = 2*deformationGradientTensor(e .* dyad(d.normalize,n.normalize)) + ...
        tensor.eye;

    end   
  end
  
  
end

