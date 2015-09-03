classdef customKernel < kernel
  % defines a kernel function as a function of the rotational angle
  
  properties
    fun = @(x) 1;
  end
      
  methods
    
    function psi = customKernel(fun,varargin)
      
      % extract parameter and halfwidth
      if nargin == 0, return;end
        
      psi.K = fun;
      psi.A = calcFourier(fun,varargin{:});
                
    end
  
    function c = char(psi)
      c = ['custom, halfwidth ' ...
        xnum2str(psi.halfwidth/degree) mtexdegchar];
    end
    
    function value = K(psi,co2)
      % the kernel function on SO(3)
      co2 = cut2unitI(co2);
      value   =  psi.fun(co2);
    end    
        
  end
end
