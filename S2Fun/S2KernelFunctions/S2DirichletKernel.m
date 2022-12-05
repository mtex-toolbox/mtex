classdef S2DirichletKernel < S2Kernel
% The spherical Dirichlet or Christoffel-Darboux kernel has the unique 
% property of being a convergent finite series in Fourier coefficients 
% with an integral of one.
% This kernel is recommended for calculating physical properties as the 
% Fourier coefficients always have a value of one for a given bandwidth.
%
% It is defined by its Legendre series
%
% $$ \psi_N(t) = \sum\limits_{n=0}^N (2n+1) \, \mathcal P_{n}(t)$$.
%
% Syntax
%
%   psi = S2DirichletKernel(N)
%
% Input
%  N - polynomial degree / bandwidth
%
% See also
% S2Kernel

 
  properties (Dependent = true)
    halfwidth % halfwidth of the kernel
  end
    
  methods
    
    
    function psi = S2DirichletKernel(N)
          
      psi.A = 2.*(0:N).'+1;
            
    end
    
    function hw = get.halfwidth(psi)
            
      hw = pi;
      
    end
        
  end
  
end