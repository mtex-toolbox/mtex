classdef SO3SobolevKernel < SO3Kernel
% The Sobolev kernel $\psi_{s}\in L^2(\mathcal{SO}(3))$ 
% is a radial symmetric kernel function depending on a parameter $s$ and 
% the bandwidth $N$.
% It is defined by its Chebyshev series
%
% $$ \psi_s(t) = \sum\limits_{n=0}^{N} (2n+1)\, (n(n+1))^s \, \mathcal
% U_{2n}(t) $$.
%
% Syntax
%   psi = SO3SobolevKernel(1.1,'bandwidth',20)
%

  properties
    s = 1;
  end
      
  methods
    
    function psi = SO3SobolevKernel(s,varargin)
      
      if nargin == 0, return;end
      psi.s = s;
      
      % extract bandwidth
      L = get_option(varargin,'bandwidth',1000);
       
      psi.A = (2*(0:L)+1) .* (0:L).^psi.s .* (1:L+1).^psi.s;

      
      psi.A = psi.cutA;
          
    end
  
    function c = char(psi)
      c = ['Sobolev, halfwidth ' ...
        xnum2str(psi.halfwidth/degree) mtexdegchar];
    end
    
  end

end
