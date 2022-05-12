classdef SO3SquareSingularityKernel < SO3Kernel
% The Squared Singularity Kernel $\psi_{\kappa}\in L^2(\mathcal{SO}(3))$  
% is a nonnegative function depending on a parameter $\kappa\in(0,1)$ and 
% is defined by its Chebyshev series
%
% $$ \psi_{\kappa}(t) = \sum\limits_{n=0}^{\infty} \hat{f}_n(\kappa)
% \, \mathcal U_{2n}(t) $$.
%
% where the chebychev coefficients follows a 3-term recurrsion
%
% $\hat{f}_0 = 1$
% $\hat{f}_1 = \frac{1+\kappa^2}{2\kappa}-\frac1{\log\frac{1+\kappa}{1-\kappa}}$
% $\hat{f}_n = \frac{(2n-3)(2n+1)(1+\kappa^2)}{(2n-1)(n-1)2\kappa} \,
% \hat{f}_{n-1}(\kappa)-\frac{2\kappa(n-2)(2n+1)}{2n-3} \,
% \hat{f}_{n-2}(\kappa)$.
%
% Syntax
%   psi = SO3SquareSingularityKernel(0.2)
%

  properties
    kappa = 90;
    C = [];
  end
      
  methods
    
    function psi = SO3SquareSingularityKernel(varargin)
        
      % extract parameter and halfwidth
      if check_option(varargin,'halfwidth')        
        error('not yet implemented!');
        %hw = get_option(varargin,'halfwidth');        
        %psi.kappa = log(2) / (1-cos(hw));
      elseif nargin > 0
        psi.kappa = varargin{1};
      end            
      
      % extract bandwidth
      L = get_option(varargin,'bandwidth',1000);
                 
      % compute Legendre coefficients
      psi.A = ones(1,L+1);
      psi.A(2) = (1+psi.kappa^2)/2/psi.kappa ...
        -1/log((1+psi.kappa)/(1-psi.kappa));

      for l=1:L-1
        psi.A(l+2) = (-2*psi.kappa*l*psi.A(l) + ...
        (2*l+1) * (1+psi.kappa^2) * psi.A(l+1))/2/psi.kappa/(l+1);
      end
      
      psi.A = psi.A .*(2*(0:L)+1);
      
      psi.A = psi.cutA;
          
    end
  
    function c = char(psi)
      c = ['de la Vallee Poussin, halfwidth ' ...
        xnum2str(psi.halfwidth/degree) mtexdegchar];
    end


    function S2K = radon(psi)
      S2K = S2Kernel(psi.A,@evalRadon);

      function value = evalRadon(t)
      % the radon transformed kernel function at
      value  = 2*psi.kappa/log((1+psi.kappa)/(1-psi.kappa)) ./ ...
            (1-2*psi.kappa*t + psi.kappa^2);
    
      end
    end
    
% double radon transform used in calcPDF
%     function value = RRK(psi,dh,dr)
%       
%       c = 2*psi.kappa/log((1+psi.kappa)/(1-psi.kappa));
%       
%       sindhdr = sqrt((1-dh.^2)*(1-dr.^2));
%       
%       value = c./...
%         (1 + psi.kappa^2 - 2*psi.kappa*(dh * dr - sindhdr)).^(0.5) ./...
%         (1 + psi.kappa^2 - 2*psi.kappa*(dh * dr + sindhdr)).^(0.5);
%     end
        
  end

end
