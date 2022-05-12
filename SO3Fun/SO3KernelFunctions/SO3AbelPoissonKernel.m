classdef SO3AbelPoissonKernel < SO3Kernel
% The Abel Poisson kernel $\psi_{\kappa}$ on SO(3) is a nonnegative function 
% depending on a parameter $\kappa \in (0,1)$ and is defined by its 
% Chebyshev series
%
% $$ \psi_{\kappa}(t) = \sum\limits_{n=0}^{\infty} (2n+1) \, \kappa^{2n} \,
% \mathcal U_{2n}(t)$$.
% 
% Syntax
%   psi = SO3AbelPoissonKernel(0.4)
%   psi = SO3AbelPoissonKernel('halfwidth',5*degree)
%
    
  properties
    kappa = 0.8;
  end
      
  methods
    
    function psi = SO3AbelPoissonKernel(varargin)
            
      % extract parameter and halfwidth
      if check_option(varargin,'halfwidth')
        hw = get_option(varargin,'halfwidth');        
        psi.kappa = fminbnd(@(kappa) (1 - 2*AP(kappa,cos(hw/2))./AP(kappa,1)).^2,0,1);
      elseif nargin > 0
        psi.kappa = varargin{1};
      end
      
      % extract bandwidth
      L = get_option(varargin,'bandwidth',1000);
      
      % compute Chebyshev coefficients
      psi.A = 1;
      for i=1:L, psi.A(i+1) = (2*i+1)*exp(log(psi.kappa)*2*i);end
      
      psi.A = psi.cutA;
          
    end
  
    function c = char(psi)
      c = ['Abel Poisson, halfwidth ' ...
        xnum2str(psi.halfwidth/degree) mtexdegchar];
    end
    
    function value = eval(psi,co2)
      % the kernel function on SO(3)
      co2 = cut2unitI(co2);
      value = AP(psi.kappa,co2);
    end
  
    function S2K = radon(psi)
      % the radon transformed kernel function
      
      S2K = S2Kernel(psi.A,@evalRadon);
      
      function value = evalRadon(t)
        t = cut2unitI(t);
        value  = (1-psi.kappa^4)./((1-2*psi.kappa^2*t+psi.kappa^4).^(3/2));
      end
    end
        
  end
end

% --------------------------------------------------------
function value = AP(kappa,co2)
value = 0.5*((1-kappa.^2)./(1-2*kappa*co2+kappa.^2).^2+...
  (1-kappa.^2)./(1+2*kappa*co2+kappa.^2).^2);
end
