classdef S2Kernel

  properties
    A % Legendre coefficients
  end

  methods
    
    function S2K = S2Kernel(A)      
      S2K.A = A(1:min(end,2048));
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

end