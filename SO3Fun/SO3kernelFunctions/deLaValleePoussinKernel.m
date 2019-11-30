classdef deLaValleePoussinKernel < kernel
% deLaValleePousinKernel
%   Detailed explanation goes here
%
% Syntax
%
%   psi = deLaValleePoussinKernel(100)
%   psi = deLaValleePoussinKernel('halfwidth',5*degree)
%

    
  properties
    kappa = 90;
    C = [];
  end
      
  methods
    
    function psi = deLaValleePoussinKernel(varargin)
      
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
  
    function c = char(psi)
      c = ['de la Vallee Poussin, halfwidth ' ...
        xnum2str(psi.halfwidth/degree) mtexdegchar];
    end
    
    function value = K(psi,co2)
      % the kernel function on SO(3)
      % K(omega) = C * cos(omega/2)^(2*kappa)
      value   =  psi.C * co2.^(2*psi.kappa);      
    end
  
    function value = DK(psi,co2)
      % the derivative of the kernel function
      % DK(omega) = - kappa * C * sin(omega/2)*cos(omega/2)^(2kappa-1)
      
      %value = -psi.C * psi.kappa * sqrt(1-co2.^2) .* co2.^(2*psi.kappa-1);
      value = -psi.C * psi.kappa * sqrt(1-co2.^2) .* co2.^(2*psi.kappa-1);
      
    end
    
    function value = RK(psi,t)
      % the radon transformed kernel function at 
      value  = (1+psi.kappa) * ((1+t)/2).^psi.kappa;
    end
    
    function value = DRK(psi,t)
      % the derivative of the radon transformed kernel function at 
      %value  = psi.kappa*(1+psi.kappa) * sqrt(1-t.^2)/2 .* ((1+t)/2).^(psi.kappa-1);
      value  = psi.kappa*(1+psi.kappa) * ((1+t)/2).^(psi.kappa-1) ./ 2;
    end
        
    function hw = halfwidth(psi)
      hw = 2*acos(0.5^(1/2/psi.kappa));
    end        
    
  end

end
