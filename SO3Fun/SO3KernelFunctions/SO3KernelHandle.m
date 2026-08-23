classdef SO3KernelHandle < SO3Kernel
  % defines a kernel function as a function of the rotational angle
  %
  % Wraps an arbitrary function of cos(omega/2) into an @SO3Kernel. Its
  % Chebyshev coefficients are computed by quadrature.
  %
  % Syntax
  %   psi = SO3KernelHandle(fun)
  %   psi = SO3KernelHandle(fun,'bandwidth',N)
  %
  % Input
  %  fun - @function_handle of cos(omega/2)
  %
  % Output
  %  psi - @SO3Kernel
  %
  % Options
  %  bandwidth - maximum harmonic degree
  %
  % Class Properties
  %  fun       - the @function_handle
  %  A         - Chebyshev coefficients
  %  bandwidth - maximum harmonic degree
  %
  % See also
  % SO3Kernel SO3DeLaValleePoussinKernel
  %
  
  properties
    fun = @(x) 1;
  end
      
  methods
    
    function psi = SO3KernelHandle(fun,varargin)
      
      % extract parameter and halfwidth
      if nargin == 0, return;end

      psi.fun = fun;
      L = get_option(varargin,'bandwidth',getMTEXpref('maxS1Bandwidth'));
      psi.A = calcFourier(psi,L,varargin{:});
      % psi.A = cutA(psi);

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
