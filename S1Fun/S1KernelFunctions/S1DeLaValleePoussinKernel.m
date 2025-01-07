classdef S1DeLaValleePoussinKernel < S1Kernel
% The $n$-th de la Vallee Poussin kernel is defined by 
% 
% $$ V_{2n}(x) = \frac{1}{n} \, \sum\limits_{j=n}^{2n-1} D_j(x) = 2F_{2n-1}(x) - F_{n-1}(x),$$
% 
% where $D_j$ denotes the $j$-th Dirichlet kernel and $F_n$ the $n$-th Fejer
% kernel.
% 
% The de la Vallee Poussin kernel is always positive and there is no 
% truncation error in Fourier space.
%
% Syntax
%   psi = S1DeLaValleePoussinKernel(n)
%
% Input
%  n - parameter (2*n is the bandwidth)
%

  properties (Dependent = true)
    halfwidth % halfwidth of the kernel
  end
    
  methods
    
    function psi = S1DeLaValleePoussinKernel(varargin)
    
      if nargin>0 && isnumeric(varargin{1})
        n = round(varargin{1});
      else
        hw = get_option(varargin,'halfwidth',2.9*degree);
        n = round(1.2/hw+1/16);
      end          
      % Fourier coefficients
      psi.fhat = [2+(-2*n:-n-1)'/n; ones(2*n+1,1); 2-(n+1:2*n)'/n];

    end
    
    
    function value = eval(psi,x)
      % evaluate the kernel function at nodes x

      n = psi.bandwidth/2;
      x = mod(x+pi,2*pi)-pi;
      value  = 1/n * (sin(n*x).^2 - sin(n*x/2).^2)./sin(x/2).^2;
      ind = abs(x)<1e-8;
      value(ind) = 3*n;
      
    end

    function hw = get.halfwidth(psi)

      % TODO: halfwidth
      n = psi.bandwidth/2;
      if n==0
        hw = 0;
      elseif n==1
        hw = acos(0.25);
      else
        hw = 1.2/(n-1/16);
      end
    end

    function c = char(psi)
      c = ['de la Vallee Poussin, halfwidth ' xnum2str(psi.halfwidth/degree) mtexdegchar];
    end
    
  end
  
end


