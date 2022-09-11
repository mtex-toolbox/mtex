classdef S2KernelHandle < S2Kernel
  % defines a kernel function as a function of the rotational angle
  
  properties
    fun = @(x) 1;
  end
      
  methods
    
    function psi = S2KernelHandle(fun,varargin)
      
      % extract parameter and halfwidth
      if nargin == 0, return;end
      
      psi.fun = fun;
      psi.A = calcFourier(psi,getMTEXpref('maxS2Bandwidth'),varargin{:});
                
    end
    
    function value = eval(psi,t)
      value = psi.fun(t);
    end    
        
  end
end