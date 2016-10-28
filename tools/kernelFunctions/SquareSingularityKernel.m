classdef SquareSingularityKernel < kernel
      
  properties
    kappa = 90;
    C = [];
  end
      
  methods
    
    function psi = SquareSingularityKernel(varargin)
        
      % extract parameter and halfwidth
      if check_option(varargin,'halfwidth')        
        error('not yet implemented!');
        %hw = get_option(varargin,'halfwidth');        
        %psi.kappa = log(2) / (1-cos(hw));
      elseif nargin > 0
        psi.kappa = varargin{1};
      end            
      
      % extract bandwidth
      L = get_option(varargin,'bandwidth',1000);
                 
      % compute Legendre coefficients
      psi.A = ones(1,L+1);
      psi.A(2) = (1+psi.kappa^2)/2/psi.kappa ...
        -1/log((1+psi.kappa)/(1-psi.kappa));

      for l=1:L-1
        psi.A(l+2) = (-2*psi.kappa*l*psi.A(l) + ...
        (2*l+1) * (1+psi.kappa^2) * psi.A(l+1))/2/psi.kappa/(l+1);
      end
      
      psi.A = psi.A .*(2*(0:L)+1);
      
      psi.A = psi.cutA;
          
    end
  
    function c = char(psi)
      c = ['de la Vallee Poussin, halfwidth ' ...
        xnum2str(psi.halfwidth/degree) mtexdegchar];
    end
    
    function value = RK(psi,t)
      % the radon transformed kernel function at 
      value  = 2*psi.kappa/log((1+psi.kappa)/(1-psi.kappa)) ./ ...
        (1-2*psi.kappa*t + psi.kappa^2);
    end
    
    function value = RRK(psi,dh,dr)
      
      c = 2*psi.kappa/log((1+psi.kappa)/(1-psi.kappa));
      
      sindhdr = sqrt((1-dh.^2)*(1-dr.^2));
      
      value = c./...
        (1 + h^2 - 2*h*(dh * dr - sindhdr)).^(0.5) ./...
        (1 + h^2 - 2*h*(dh * dr + sindhdr)).^(0.5);
    end
        
  end

end
