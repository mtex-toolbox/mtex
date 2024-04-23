classdef SO3vonMisesFisherKernel < SO3Kernel
% The von Mises Fisher kernel $\psi_{\kappa}\in L^2(\mathcal{SO}(3))$ 
% is a nonnegative function depending on a parameter $\kappa>0$ and 
% is defined by its Chebyshev series
%
% $$ \psi_{\kappa}(t) = \sum\limits_{n=0}^{\infty} 
% \frac{\mathcal{I}_n(\kappa}-\mathcal{I}_{n+1}(\kappa)}
% {\mathcal{I}_0(\kappa)-\mathcal{I}_1(\kappa)}  \, \mathcal U_{2n}(t)$$ 
%
% or directly by
%
% $$ \psi_{\kappa}(\cos\frac{\omega(R)}2) = \frac1{\mathcal{I}_0(\kappa)-\mathcal{I}_1(\kappa)}
% \, \mathrm{e}^{\kappa \cos\omega(R)}$$
% 
% while $\mathcal I_n,\,n\in\mathbb N_0$ denotes the the modified Bessel 
% functions of first kind
%
% $$ \mathcal I_n (\kappa) = \frac1{\pi} \int_0^{\pi} \mathrm e^{\kappa \,
% \cos \omega} \, \cos n\omega \, \mathrm d\omega $$.
%
% Syntax
%   psi = SO3vonMisesFisherKernel(100)
%   psi = SO3vonMisesFisherKernel('halfwidth',5*degree)
%
% Input
%  kappa - kernel parameter
%
% Output
%  psi - @SO3vonMisesFisherKernel
%

properties
  kappa = 90;
  C = [];
end
      
methods
    
  function psi = SO3vonMisesFisherKernel(varargin)
 
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
    psi.A = ones(1,L+1);
    b = besseli(0:L+1,psi.kappa);
    psi.A(2:end) = diff(b(2:end)) ./ (b(2)-b(1));
    
    psi.A = psi.cutA;
    
  end
  
  function c = char(psi)
    c = ['van Mises Fisher, halfwidth ' ...
      xnum2str(psi.halfwidth/degree) mtexdegchar];
  end
    
  
  function value = eval(psi,co2)    
    co2 = cut2unitI(co2);
    if psi.kappa < 500
      value = psi.C * exp(psi.kappa*cos(acos(co2)*2));
    else
      error('too small halfwidth - not yet supported');
    end
  end
  
  function value = grad(psi,co2)
    % the derivative of the kernel function
    % DK(omega) = - kappa * C * sin(omega/2)*cos(omega/2)^(2kappa-1)
    
    if nargin == 2
      %value = -psi.C * psi.kappa * sqrt(1-co2.^2) .* co2.^(2*psi.kappa-1);
      value = -psi.C * psi.kappa * sqrt(1-co2.^2) .* co2.^(2*psi.kappa-1);
    else      
      value = SO3KernelHandle(@(co2) -psi.C * psi.kappa * sqrt(1-co2.^2) .* co2.^(2*psi.kappa-1));
    end
    
  end
    
  function S2K = radon(psi)
      % the radon transformed kernel function
      
      S2K = S2Kernel(psi.A,@evalRadon);
      % TODO: S2K = S2KernelBessel
      
      function value = evalRadon(t)
        t = cut2unitI(t);
        value = exp(psi.kappa*(t-1)/2) .* ...
          besseli(0,psi.kappa *(1+t)/2)*psi.C;
      end
  end
  
  function hw = halfwidth(psi)
      hw = acos(1-log(2)/psi.kappa);      
    end
  
end

end
