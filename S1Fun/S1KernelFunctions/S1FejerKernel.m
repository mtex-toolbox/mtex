classdef S1FejerKernel < S1Kernel
% The Fejer kernel has the unique property of being a convergent 
% finite series in Fourier coefficients with an integral of one. In
% contrast to Dirichlet kernel the Fejer kernel is nonnegative.
%
% It is defined by its Fourier series
%
% $$ F_n(x) = \frac{1}{n+1} \, \sum\limits_{j=0}^n D_j(x),$$
%
% where $D_j$ is the j-th Dirichlet kernel.
%
% Syntax
%   psi = S1FejerKernel(n)
%
% Input
%  n - bandwidth
%
 
  properties (Dependent = true)
    halfwidth % halfwidth of the kernel
  end
    
  methods
    
    
    function psi = S1FejerKernel(n)
          
      if nargin==0
        n = 25;
      end

      psi.fhat = 1 - abs(-n:n).'/(n+1);
            
    end
    
    function hw = get.halfwidth(psi)
            
      hw = pi;
      
    end

    function v = eval(sF,x)
      n = sF.bandwidth;
      x = mod(x+pi,2*pi)-pi;
      v = 1/(n+1) * (sin( (n+1)*x/2 ) ./ sin(x/2)).^2;
      ind = abs(x)<1e-8;
      v(ind) = n+1;
    end

    function c = char(psi)
      c = ['Fejer, halfwidth ' xnum2str(psi.halfwidth/degree) mtexdegchar];
    end
        
  end
  
end