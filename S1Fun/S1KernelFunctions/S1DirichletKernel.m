classdef S1DirichletKernel < S1Kernel
% The Dirichlet kernel has the unique property of being a convergent 
% finite series in Fourier coefficients with an integral of one.
% This kernel is recommended for calculating physical properties as the 
% Fourier coefficients always have a value of one for a given bandwidth.
%
% It is defined by its Fourier series
%
% $$ D_n(x) = \sum\limits_{k=-n}^n \mathrm{e}^{\mathrm{i}kx}$$.
%
% Syntax
%
%   psi = S1DirichletKernel(n)
%
% Input
%  n - bandwidth
%
 
  properties (Dependent = true)
    halfwidth % halfwidth of the kernel
  end
    
  methods
    
    
    function psi = S1DirichletKernel(n)
      
      if nargin==0
        n = 25;
      end

      psi.fhat = 0.*(-n:n).'+1;
            
    end
    
    function hw = get.halfwidth(psi)
            
      hw = pi;
      
    end

    function v = eval(sF,x)
      n = sF.bandwidth;
      x = mod(x+pi,2*pi)-pi;
      v = sin( (2*n+1)*x/2 ) ./ sin(x/2);
      ind = abs(x)<1e-8;
      v(ind) = (2*n+1)*cos( (2*n+1)*x(ind)/2 ) ./ cos(x(ind)/2);
    end

    function c = char(psi)
      c = ['Dirichlet, halfwidth ' xnum2str(psi.halfwidth/degree) mtexdegchar];
    end
        
  end
  
end