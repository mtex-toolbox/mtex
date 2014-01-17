classdef squaredSingularityKernel < kernel
      
  properties
    kappa = 90;
    C = [];
  end
      
  methods
    
    function psi = deLaValeePoussinKernel(varargin)
      
  
      psi = psi.cutA;
          
    end
  
    function c = char(psi)
      c = ['de la Vallee Poussin, halfwidth ' ...
        xnum2str(psi.halfwidth/degree) mtexdegchar];
    end
    
    function value = K(psi,co2)
      % the kernel function on SO(3)
      value   =  psi.C * co2.^(2*psi.kappa);      
    end
  
    function value = RK(psi,t)
      % the radon transformed kernel function at 
      value  = 2*psi.kappa/log((1+psi.kappa)/(1-psi.kappa)) ./ (1-2*psi.kappa*t+psi.kappa^2);
    end
        
  end

end
