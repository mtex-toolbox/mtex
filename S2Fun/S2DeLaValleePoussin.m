classdef S2DeLaValleePoussin < S2Kernel
%
%
% Syntax
%
%   psi = S2DeLaValleePoussin(20)
%   psi = S2DeLaValleePoussin('halfwidth',10*degree)
%
% Input
%  kappa - kernel parameter
%
% Options
%  halfwidth - angle at which the kernel function has reduced to half its peak value  
%  bandwidth - harmonic degree
%
% See also
% S2Kernel



  properties
    kappa % kernel parameter
  end
  
  properties (Dependent = true)
    halfwidth % halfwidth of the kernel
  end
    
  methods
    
    
    function psi = S2DeLaValleePoussin(varargin)
    
      % extract parameter and halfwidth
      if nargin > 0 && isnumeric(varargin{1})
        psi.kappa = varargin{1};
      else
        hw = get_option(varargin,'halfwidth',10*degree);
        psi.kappa = 0.5 * log(0.5) / log(cos(hw/2));
      end
      
      % extract bandwidth
      L = get_option(varargin,'bandwidth',round(psi.kappa));
            
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
    
    function hw = get.halfwidth(psi)
            
      % ((1+hw)/2)^kappa != 0.5
      hw = acos(2*(0.5)^(1/psi.kappa) - 1);
      
    end
        
  end
  
end