classdef S2Kernel

  properties
    A % Legendre coefficients
  end

  methods
    
    function S2K = S2Kernel(A)   
      if nargin == 0, return; end
      
      if isa(A,'S2Kernel')
        S2K.A = A.A;
      else
        S2K.A = A(1:min(end,2048));
      end
    end

    function v = eval(S2K,x)
      % evaluate the kernel function at nodes x
    
      % TODO: make this faster using a polynomial transform and a nfct
      v = ClenshawL(S2K.A,x);      
    end

    function plot(S2K,varargin)      
      x = linspace(-1,1,1000);
      plot(acos(x)./degree,S2K.eval(x),varargin{:});     
    end

  end

  methods (Static = true)
    function S2K = quadrature(fun,varargin)
      
      % TODO: implement this using the fpt and the ndct
      t = chebfun(fun);
      B = chebcoeffs(t);
      A = cheb2leg(B);
      S2K = S2Kernel(A);          
      
      % initialize the fast polynomial transform
            
    end
  end

  methods (Access=protected)        
    function A = cutA(psi)
      % cut of Chebyshev coefficients when they are sufficently small
      
      epsilon = getMTEXpref('FFTAccuracy',1E-2) / 150;
      A = psi.A(:);
      A = A ./ ((1:length(A)).^2).';
      ind = find(A(2:end)<=max(min([A(2:end);10*epsilon]),epsilon),1,'first');
      A = psi.A(1:min([ind+1,length(A)]));
    end
  end
end