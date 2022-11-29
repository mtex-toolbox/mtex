classdef SO3BumpKernel < SO3Kernel
% The Bump kernel is a radial symmetric kernel function depending on a 
% parameter $r\in (0,pi)$. The function value is 0, if the angle is greater
% then the halfwidth $r$. Otherwise it is has a contstant value, such that 
% the mean of the kernel function on $\mathcal{SO}(3)$ is 1. 
% Hence we use the open set $U_r = \{ R \in \mathcal{SO}(3) \,|~ |\omega(R)|<r \}$
% and define the bump kernel $\psi_r : \matcal{SO}(3) \to \mathbb R$ by
%
% $$ \psi_r(R) = \frac1{|U_r|} \mathbf{1}_{R \in U_r} $$.
%
% Syntax
%   psi = SO3BumpKernel(40*degree)
%
% Options
%  halfwidth - angle at which the kernel function has reduced to half its peak value  
%  bandwidth - harmonic degree
%
% See also
% SO3Kernel
    
  properties
    delta = 10*degree;
  end
      
  methods
    
    function psi = SO3BumpKernel(varargin)
    
      % extract parameter and halfwidth
      if check_option(varargin,'halfwidth')
        psi.delta = get_option(varargin,'halfwidth');               
      elseif nargin>0
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
    
    function value = eval(psi,co2)
      % the kernel function on SO(3)      
      value = (pi/(psi.delta-sin(psi.delta))) * ...
        (co2>cos(psi.delta/2));      
    end

    function value = grad(psi,co2)
      % the derivative of the kernel function
      if nargin == 2
        value = 0*co2;
      else
        value = SO3Kernel(0);
      end
    
    end
    
  
    function S2K = radon(psi)
            
      S2K = S2Kernel(psi.A,@evalRadon);
      
      function value = evalRadon(t)
        % the radon transformed kernel function at
        t = cut2unitI(t);
        value = zeros(size(t));
        s = cos(psi.delta/2)./sqrt((1+t)./2);
        ind = s<=1;
        value(ind) = (pi/(psi.delta-sin(psi.delta))) * ...
          2/pi*acos(s(ind));
      end
    end
        
    function hw = halfwidth(psi)
      hw = psi.delta;
    end
  end
end
