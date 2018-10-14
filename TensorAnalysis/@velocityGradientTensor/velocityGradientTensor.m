classdef velocityGradientTensor < tensor
  
  methods
    function L = velocityGradientTensor(varargin)
      L = L@tensor(varargin{:},'rank',2);
    end    

    function E = sym(L)
      E = strainRateTensor(sym@tensor(L));
    end
    
    function R = antiSym(L)
      R = spinTensor(antiSym@tensor(L));
    end

  end
  
   
  methods (Static = true)
    
    function L = pureShear(exp,comp,e)
      % define uniaxial compression tensor
      %
      % Syntax
      %   L = velocityGradientTensor.uniaxialCompression(d,r)
      %
      % Input
      %  exp  - @vector3d expansion direction
      %  comp - @vector3d compression direction
      %  e - strain rate
      %
      % Output
      %  L - @velocityGradientTensor
      %           
 
      if nargin == 2, e = 1; end

      v1 = normalize(exp - comp);
      v2 = normalize(exp + comp);

      L = 2*velocityGradientTensor(e .* (dyad(v1,v2) + dyad(v1,v2)'));

    end


    function L = simpleShear(v1,v2,e)
      % define uniaxial compression tensor
      %
      % Syntax
      %   L = velocityGradientTensor.uniaxialCompression(d,r)
      %
      % Input
      %  v1 - @vector3d shear direction
      %  v2 - @vector3d normal direction ???
      %  e - strain rate
      %
      % Output
      %  L - @velocityGradientTensor
      %           
    
      if nargin == 2, e = 1; end
      
      L = 2*velocityGradientTensor(e .* dyad(v1.normalize,v2.normalize));

    end
    
    
        
    function L = planeStrain(v1,v2,gamma)
      
      L = velocityGradientTensor();
    end
    
    function L = uniaxialCompression(d,e)
      % define uniaxial compression tensor
      %
      % Syntax
      %   L = velocityGradientTensor.uniaxialCompression(d,r)
      %
      % Input
      %  d - @vector3d compression direction
      %  e - strain rate
      %
      % Output
      %  L - @velocityGradientTensor
      %           
    
      if nargin == 0, d = vector3d.Z; end
      if nargin <= 1, e = 1; end
      
      rot = rotation.map(d,xvector);
      
      L = rot * (e .* velocityGradientTensor(diag([1,-0.5,-0.5])));
      
    end

    function L = spin(omega)
      % define a spin tensor
      
      M = zeros([3,3,size(omega)]);
      M(2,1,:) = omega.z;
      M(3,1,:) = -omega.y;
      M(3,2,:) = omega.x;

      M(1,2,:) = -omega.z;
      M(1,3,:) = omega.y;
      M(2,3,:) = -omega.x;

      L = velocityGradientTensor(M);

    end
  end
end
