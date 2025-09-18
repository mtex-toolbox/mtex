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
      if nargin > 1 && isnumeric(varargin{1})
        psi.A = varargin{1};
      else
        psi.A = calcFourier(psi,getMTEXpref('maxS2Bandwidth'),varargin{:});
      end
                
    end
    
    function value = eval(psi,t)

      if isa(t,'vector3d'), t = dot(t,zvector); end

      value = psi.fun(t);
    end

    function S2K = mtimes(a,S2K)
      if isa(S2K,"double"), [a,S2K] = deal(S2K,a); end

      S2K.A = a * S2K.A;
      S2K.fun = @(t) a * S2K.fun(t);

    end


        
  end
end