classdef SO3deLaValleePoussin < SO3Kernel
% de La Vallee Pousin kernel on SO(3)
%
% Syntax
%
%   psi = SO3deLaValleePoussin(100)
%   psi = SO3deLaValleePoussin('halfwidth',5*degree)
%

properties
  kappa = 90;
  C = [];
end
      
methods
    
  function psi = SO3deLaValleePoussin(varargin)
    
    % extract parameter and halfwidth
    if check_option(varargin,'halfwidth')
      hw = get_option(varargin,'halfwidth');
      psi.kappa = 0.5 * log(0.5) / log(cos(hw/2));
    elseif nargin > 0
      psi.kappa = varargin{1};
    end
    
    % extract bandwidth
    L = get_option(varargin,'bandwidth',round(psi.kappa));
    
    % some constant
    psi.C = beta(1.5,0.5)/beta(1.5,psi.kappa+0.5);
    
    % compute Chebyshev coefficients
    psi.A = ones(1,L+1);
    psi.A(2) = psi.kappa/(psi.kappa+2);
    
    for l=1:L-1
      psi.A(l+2) = ((psi.kappa-l+1) * psi.A(l) - ...
        (2*l+1) * psi.A(l+1)) / (psi.kappa + l + 2);
    end
    
    for l=0:L, psi.A(l+1) = (2*l+1) * psi.A(l+1); end
    
    psi.A = psi.cutA;
    
  end
  
  function c = char(psi)
    c = ['de la Vallee Poussin, halfwidth ' ...
      xnum2str(psi.halfwidth/degree) mtexdegchar];
  end
    
  
  function value = eval(psi,co2)    
    value   =  psi.C * co2.^(2*psi.kappa);
  end
  
  function value = grad(psi,co2)
    % the derivative of the kernel function
    % DK(omega) = - kappa * C * sin(omega/2)*cos(omega/2)^(2kappa-1)
    
    %value = -psi.C * psi.kappa * sqrt(1-co2.^2) .* co2.^(2*psi.kappa-1);
    value = -psi.C * psi.kappa * sqrt(1-co2.^2) .* co2.^(2*psi.kappa-1);
  end
    
  function S2K = radon(psi)
    S2K = S2DeLaValleePoussin(psi.kappa);
  end
  
  function hw = halfwidth(psi)
    hw = 2*acos(0.5^(1/2/psi.kappa));
  end
  
end

end
