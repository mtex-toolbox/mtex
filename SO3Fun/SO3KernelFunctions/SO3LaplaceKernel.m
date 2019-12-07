classdef SO3LaplaceKernel < SO3Kernel
            
  methods
    
    function psi = SO3LaplaceKernel(varargin)
            
      % extract bandwidth
      L = get_option(varargin,'bandwidth',1000);
             
      % compute Chebyshev coefficients
      psi.A(1) = 0;
      for i=1:L
        psi.A(i+1) = (2*i + 1)/(4*i^2*(2*i + 2)^2);
      end
      
      psi.A = psi.cutA;
          
    end
  
    function c = char(psi)
      c = ['Laplace, halfwidth ' ...
        xnum2str(psi.halfwidth/degree) mtexdegchar];
    end        
        
  end

end
