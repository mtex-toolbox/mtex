classdef velocityGradientTensor < tensor
  %
  %
  % since solids are no compressible the all velovity gradient tensors have
  % traec 0
  
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
    
    
    L = uniaxial(d,e)
    
    L = pureShear(exp,comp,e)

    L = simpleShear(d,n,e)
    
    
        
    function L = planeStrain(v1,v2,gamma)      
      
      L = velocityGradientTensor();
    end

    function L = spin(varargin)
      % define a spin tensor
      
      L = spinTensor(varargin{:});

    end
  end
end
