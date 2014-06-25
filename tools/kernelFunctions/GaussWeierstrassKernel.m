classdef GaussWeierstrassKernel < kernel
      
  properties
    kappa = 0.1;
  end
      
  methods
    
    function psi = GaussWeierstrassKernel(varargin)
      
      % extract parameter and halfwidth
      if check_option(varargin,'halfwidth')
        error('halfwidth argument not yet supported with Gauss kernel')
      elseif nargin > 0
        psi.kappa = varargin{1};
      end
      
      % extract bandwidth
      L = get_option(varargin,'bandwidth',1000);
      
      % compute Legendre coefficients
      psi.A = ones(1,L+1);
      for i=1:L, psi.A(i+1) = (2*i+1)*exp(-i*(i+1)*psi.kappa);end
      
      psi.A = psi.cutA;
          
    end
  
    function c = char(psi)
      c = ['Gauss Weierstrass, halfwidth ' ...
        xnum2str(psi.halfwidth/degree) mtexdegchar];
    end
        
  end

end
