classdef SO3LaplaceKernel < SO3Kernel
% The Laplace kernel $\psi\in L^2(\mathcal{SO}(3))$ is a radial symmetric 
% kernel function which is defined by its Chebyshev series
%
% $$ \psi(t) = \sum\limits_{n=0}^{\infty} \frac{(2n+1)}{4\,n^2\,(2n+2)^2}
% \, \mathcal U_{2n}(t) $$.
%
% Syntax
%   psi = SO3LaplaceKernel
%
        
  methods
    
    function psi = SO3LaplaceKernel(varargin)
            
      % extract bandwidth
      L = get_option(varargin,'bandwidth',1000);
             
      % compute Chebyshev coefficients
      psi.A(1) = 0;
      for i=1:L
        psi.A(i+1) = (2*i + 1)/(4*i^2*(2*i + 2)^2);
      end
      
      psi.A = psi.cutA;
          
    end
  
    function c = char(psi)
      c = ['Laplace, halfwidth ' ...
        xnum2str(psi.halfwidth/degree) mtexdegchar];
    end        
        
  end

end
