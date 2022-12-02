classdef SO3KernelHandle < SO3Kernel
  % defines a kernel function as a function of the rotational angle
  
  properties
    fun = @(x) 1;
  end
      
  methods
    
    function psi = SO3KernelHandle(fun,varargin)
      
      % extract parameter and halfwidth
      if nargin == 0, return;end
      
      psi.fun = fun;
      psi.A = calcFourier(psi,getMTEXpref('maxS2Bandwidth'),varargin{:});
                
    end
  
    function c = char(psi)
      c = ['custom, halfwidth ' ...
        xnum2str(psi.halfwidth/degree) mtexdegchar];
    end
    
    function value = eval(psi,co2)
      % the kernel function on SO(3)
      co2 = cut2unitI(co2);
      value   =  psi.fun(co2);
    end    
        
  end
end
