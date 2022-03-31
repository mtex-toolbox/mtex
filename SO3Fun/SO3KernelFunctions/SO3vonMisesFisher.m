classdef SO3vonMisesFisher < SO3Kernel
% de La Vallee Pousin kernel on SO(3)
%
% Syntax
%
%   psi = SO3vonMisesFisher(100)
%   psi = SO3vonMisesFisher('halfwidth',5*degree)
%
% Input
%
% Output
%
%

properties
  kappa = 90;
  C = [];
end
      
methods
    
  function psi = SO3vonMisesFisher(varargin)
 
    % extract parameter and halfwidth
    if check_option(varargin,'halfwidth')
      hw = get_option(varargin,'halfwidth');
      psi.kappa = log(2) / (1-cos(hw));
    elseif nargin > 0
      psi.kappa = varargin{1};
    end
      
    % extract bandwidth
    L = get_option(varargin,'bandwidth',1000);
            
    % some constant
    psi.C = 1/(besseli(0,psi.kappa)-besseli(1,psi.kappa));
      
    % compute Legendre coefficients
    psi.A = ones(L+1,1);
    b = besseli(0:L+1,psi.kappa);
    psi.A(2:end) = diff(b(2:end)) ./ (b(2)-b(1));
    
    psi.A = psi.cutA;
    
  end
  
  function c = char(psi)
    c = ['van Mises Fisher, halfwidth ' ...
      xnum2str(psi.halfwidth/degree) mtexdegchar];
  end
    
  
  function value = eval(psi,co2)    
    co2 = cut2unitI(co2);
    if psi.kappa < 500
      value = psi.C * exp(psi.kappa*cos(acos(co2)*2));
    else
      error('too small halfwidth - not yet supported');
    end
  end
  
  function value = grad(psi,co2)
    % the derivative of the kernel function
    % DK(omega) = - kappa * C * sin(omega/2)*cos(omega/2)^(2kappa-1)
    
    if nargin == 2
      %value = -psi.C * psi.kappa * sqrt(1-co2.^2) .* co2.^(2*psi.kappa-1);
      value = -psi.C * psi.kappa * sqrt(1-co2.^2) .* co2.^(2*psi.kappa-1);
    else      
      value = SO3KernelHandle(@(co2) -psi.C * psi.kappa * sqrt(1-co2.^2) .* co2.^(2*psi.kappa-1));
    end
    
  end
    
%   function S2K = radon(psi)
% 
%     % TODO !!
% 
%     % the radon transformed kernel function at
%     t = cut2unitI(t);
%     value = exp(psi.kappa*(t-1)/2) .* ...
%       besseli(0,psi.kappa *(1+t)/2)/...
%       (besseli(0,psi.kappa)-besseli(1,psi.kappa));
%     
%     S2K = S2KernelBessel;
%   end
  
  function hw = halfwidth(psi)
      hw = acos(1-log(2)/psi.kappa);      
    end
  
end

end
