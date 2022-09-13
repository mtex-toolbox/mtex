classdef S2DeLaValleePoussinKernel < S2Kernel
% The spherical de la Vallee Poussin kernel is defined by 
% 
% $$ K(t) = (1+\kappa)\,(\frac{1+t}{2})^{kappa}$$ 
% 
% for $t\in[0,1]$. The de la Vallee Poussin kernel additionaly has the 
% unique property that for a given halfwidth it can be described exactly 
% by a finite number of Fourier coefficients. This kernel is recommended
% for Texture analysis as it is always positive and there is no truncation 
% error in Fourier space.
%
% Hence we can define the de la Vallee Poussin kernel $\psi_{\kappa}$ 
% depending on a parameter $\kappa \in \mathbb N \setminus \{0\}$ by its 
% finite Legendre polynomial expansion
%
% $$ \psi_{\kappa}(t) = \sum\limits_{n=0}^{L} a_n(\kappa) \mathcal P_{n}(t)$$.
%
% We obtain the Legendre coefficients $a_n(\kappa)$ by $a_0=1$, 
% $a_1=\frac{\kappa}{2+\kappa}$ and the three term recurence relation
%
% $$ (\kappa+l+2) a_{l+1} = -(2l+1)\,a_l + (\kappa-l+1)\,a_{l-1}$$.
%
% Syntax
%
%   psi = S2DeLaValleePoussinKernel(20)
%   psi = S2DeLaValleePoussinKernel('halfwidth',10*degree)
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
    
    
    function psi = S2DeLaValleePoussinKernel(varargin)
    
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

    function value = grad(psi,varargin)
      % the derivative of the radon transformed kernel function at
      %value  = -psi.kappa*(1+psi.kappa) * sqrt(1-t.^2)/2 .* ((1+t)/2).^(psi.kappa-1);
      %value  = psi.kappa*(1+psi.kappa) * ((1+t)/2).^(psi.kappa-1) ./ 2;
      if check_option(varargin,'polynomial')
        innerGrad = @(t) 1;
      else
        innerGrad = @(t) -sqrt(1-t.^2);
      end

      if nargin >= 2 && isnumeric(varargin{1})
        t = varargin{1};
        value  = psi.kappa*(1+psi.kappa)/2 * innerGrad(t) .* ((1+t)/2).^(psi.kappa-1);
      else
        value = S2KernelHandle(@(t) psi.kappa*(1+psi.kappa)/2 * innerGrad(t) .* ((1+t)/2).^(psi.kappa-1));
      end

    
    end
    
    function hw = get.halfwidth(psi)
            
      % ((1+hw)/2)^kappa != 0.5
      hw = acos(2*(0.5)^(1/psi.kappa) - 1);
      
    end
    
    function c = char(psi)
      c = ['de la Vallee Poussin, halfwidth ' ...
        xnum2str(psi.halfwidth/degree) mtexdegchar];
    end
        
  end
  
end