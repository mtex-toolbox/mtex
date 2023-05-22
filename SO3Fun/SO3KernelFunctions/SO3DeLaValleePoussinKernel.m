classdef SO3DeLaValleePoussinKernel < SO3Kernel
% The rotational de la Vallee Poussin kernel is defined by 
% 
% $$ K(t) = \frac{B(\frac32,\frac12)}{B(\frac32,\kappa+\frac12)}\,t^{2\kappa}$$ 
% 
% for $t\in[0,1]$, where $B$ denotes the Beta function. The de la Vallee 
% Poussin kernel additionaly has the unique property that for
% a given halfwidth it can be described exactly by a finite number of 
% Fourier coefficients. This kernel is recommended for Texture analysis as 
% it is always positive in orientation space and there is no truncation 
% error in Fourier space.
%
% Hence we can define the de la Vallee Poussin kernel $\psi_{\kappa}$ 
% depending on a parameter $\kappa \in \mathbb N \setminus \{0\}$ by its 
% finite Chebyshev expansion
%
% $$ \psi_{\kappa}(t) = \frac{(\kappa+1)\,2^{2\kappa-1}}{\binom{2\kappa-1}{\kappa}}
% \, t^{2\kappa}  = \binom{2\kappa+1}{\kappa}^{-1} \, 
% \sum\limits_{n=0}^{\kappa} (2n+1)\,\binom{2\kappa+1}{\kappa-n} \,
% \mathcal U_{2n}(t)$$.
%
% Syntax
%   psi = SO3DeLaValleePoussinKernel(100)
%   psi = SO3DeLaValleePoussinKernel('halfwidth',5*degree)
%
% Input
%  kappa - kernel parameter
%
% Options
%  halfwidth - angle at which the kernel function has reduced to half its peak value  
%  bandwidth - harmonic degree
%
% See also
% SO3Kernel

properties
  kappa = 90;
  C = [];
end
      
methods
    
  function psi = SO3DeLaValleePoussinKernel(varargin)
    
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
    
    % compute Chebyshev coefficients
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
    
  
  function value = eval(psi,co2)    
    value   =  psi.C * co2.^(2*psi.kappa);
  end
  
  function value = grad(psi,co2)
    % the derivative of the kernel function
    % DK(omega) = - kappa * C * sin(omega/2)*cos(omega/2)^(2kappa-1)
    
    if nargin == 2
      value = -psi.C * psi.kappa * sqrt(1-co2.^2) .* co2.^(2*psi.kappa-1);
      %value = 2 * psi.C * psi.kappa *co2.^(2*psi.kappa-1);
    else      
      value = SO3KernelHandle(@(co2) -psi.C * psi.kappa * sqrt(1-co2.^2) .* co2.^(2*psi.kappa-1));
    end
    
  end
    
  function S2K = radon(psi)
    S2K = S2DeLaValleePoussinKernel(psi.kappa);
  end
  
  function hw = halfwidth(psi)
    hw = 2*acos(0.5^(1/2/psi.kappa));
  end
  
end

end
