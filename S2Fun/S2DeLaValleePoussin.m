classdef S2DeLaValleePoussin < S2Kernel

  properties
    kappa % kernel parameter
  end
  
   
  methods
    
    
    function psi = S2DeLaValleePoussin(varargin)
    
      % extract parameter and halfwidth
      if check_option(varargin,'halfwidth')
        hw = get_option(varargin,'halfwidth');
        psi.kappa = 0.5 * log(0.5) / log(cos(hw/2));
      elseif nargin > 0
        psi.kappa = varargin{1};
      end
      
      % extract bandwidth
      L = get_option(varargin,'bandwidth',round(psi.kappa));
            
      % some constant
      psi.C = beta(1.5,0.5)/beta(1.5,psi.kappa+0.5);
      
      % compute Legendre coefficients
      psi.A = ones(1,L+1);
      psi.A(2) = psi.kappa/(psi.kappa+2);

      for l=1:L-1
        psi.A(l+2) = ((psi.kappa-l+1) * psi.A(l) - ...
          (2*l+1) * psi.A(l+1)) / (psi.kappa + l + 2); 
      end

      for l=0:L, psi.A(l+1) = (2*l+1) * psi.A(l+1); end

      psi.A = psi.cutA;      
    end
    
    
    function value = eval(psi,t)
      % evaluate the kernel function at nodes x

      value  = (1+psi.kappa) * ((1+t)/2).^psi.kappa;
      
    end
    
  end
  
end