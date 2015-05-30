classdef bumpKernel < kernel
  % the bump kernel
  %   Detailed explanation goes here
    
  properties
    delta = 10*degree;
  end
      
  methods
    
    function psi = bumpKernel(varargin)
    
      % extract parameter and halfwidth
      if check_option(varargin,'halfwidth')
        psi.delta = get_option(varargin,'halfwidth');               
      else
        psi.delta = varargin{1};
      end
      
      % extract bandwidth
      L = get_option(varargin,'bandwidth',1000);
      
      % compute Chebyshev coefficients      
      psi.A = calcFourier(psi,L,psi.delta);
      
    end
  
    function c = char(psi)
      c = ['bump, halfwidth ' ...
        xnum2str(psi.halfwidth/degree) mtexdegchar];
    end
    
    function value = K(psi,co2)
      % the kernel function on SO(3)      
      value = (pi/(psi.delta-sin(psi.delta))) * ...
        (co2>cos(psi.delta/2));      
    end
  
    function value = RK(psi,t)
      % the radon transformed kernel function at 
      t = cut2unitI(t);
      value = zeros(size(t));
      s = cos(psi.delta/2)./sqrt((1+t)./2);
      ind = s<=1;
      value(ind) = (pi/(psi.delta-sin(psi.delta))) * ...
        2/pi*acos(s(ind));      
    end
        
    function hw = halfwidth(psi)
      hw = psi.delta;
    end
  end
end
