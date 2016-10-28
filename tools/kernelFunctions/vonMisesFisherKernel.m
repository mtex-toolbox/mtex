classdef vonMisesFisherKernel < kernel
    
  properties
    kappa = 45;
    C = [];
  end
      
  methods
    
    function psi = vonMisesFisherKernel(varargin)
      
      % extract parameter and halfwidth
      if check_option(varargin,'halfwidth')
        hw = get_option(varargin,'halfwidth');
        psi.kappa = log(2) / (1-cos(hw));        
      elseif nargin > 0
        psi.kappa = varargin{1};
      end            
      
      % extract bandwidth
      L = get_option(varargin,'bandwidth',1000);
            
      % some constant
      psi.C = 1/(besseli(0,psi.kappa)-besseli(1,psi.kappa));
      
      % compute Legendre coefficients
      psi.A = ones(L+1,1);
      b = besseli(0:L+1,psi.kappa);
      psi.A(2:end) = diff(b(2:end)) ./ (b(2)-b(1));
    
      psi.A = psi.cutA;
          
    end
  
    function c = char(psi)
      c = ['van Mises Fisher, halfwidth ' ...
        xnum2str(psi.halfwidth/degree) mtexdegchar];
    end
    
    function value = K(psi,co2)
      % the kernel function on SO(3)
      
      co2 = cut2unitI(co2);
      if psi.kappa < 500        
        value = psi.C * exp(psi.kappa*cos(acos(co2)*2));        
      else
        error('too small halfwidth - not yet supported');
      end
    end
  
    function value = RK(psi,t)
      % the radon transformed kernel function at 
      t = cut2unitI(t);
      value = exp(psi.kappa*(t-1)/2) .* ...
        besseli(0,psi.kappa *(1+t)/2)/...
        (besseli(0,psi.kappa)-besseli(1,psi.kappa));      
    end
        
    function hw = halfwidth(psi)
      hw = acos(1-log(2)/psi.kappa);      
    end
        
  end

end
