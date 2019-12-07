classdef S2Kernel

  properties
    A % Legendre coefficients
  end

  properties (Dependent=true)
    bandwidth % harmonic degree
  end
  
  properties (Hidden = true)
    evalFun = []
  end
  
  
  methods
    
    function S2K = S2Kernel(A, evalFun)
      if nargin == 0, return; end
      
      if isa(A,'S2Kernel')
        S2K.A = A.A;
      else
        S2K.A = A(1:min(end,2048));
      end
      
      if nargin == 2, S2K.evalFun = evalFun; end
    end

    function v = eval(S2K,x)
      % evaluate the kernel function at nodes x
    
      % TODO: make this faster using a polynomial transform and a nfct
      if isempty(S2K.evalFun)
        v = ClenshawL(S2K.A,x);
      else
        v = S2K.evalFun(x);
      end
    end

    function plot(S2K,varargin)      
      
      omega = get_option(varargin,'omega',linspace(0,180*degree,1000));
      
      f = S2K.eval(cos(omega));
      
      if check_option(varargin,'symmetric')
        omega = [-omega,fliplr(omega)];
        f = [f,fliplr(f)];
      end
      
      optiondraw(plot(omega./degree,f),varargin{:});
    end
    
    function display(S2K)
      displayClass(S2K,inputname(1));      
      disp(['  bandwidth: ',int2str(S2K.bandwidth)]);
      try
        disp(['  halfwidth: ',xnum2str(S2K.halfwidth/degree) mtexdegchar]);
      end
      disp(' ');
    end

    function L = get.bandwidth(psi)
      L = length(psi.A)-1;
    end
    
    function psi = set.bandwidth(psi,L)
      psi.A = psi.A(1:min(L+1,end));        
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