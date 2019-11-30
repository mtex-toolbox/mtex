classdef SchulzDefousingKernel < S2Kernel
%
%
% Syntax
%
%   psi = SchulzDefousingKernel(mu*t,theta)
%
% Input
%  mu - absorption coefficient (1/cm)
%  t  - penetration depth (cm)
%  theta - Bragg angle
%
% See also
% S2Kernel PoleFigure/correct

  properties
    mu_t  = 1            % mu * t 
    theta = 45*degree  % Bragg angle
    r     = 1            % beam width in mm
    w     = 2            % width of the receiving slit in mm
    d     = 200          % distance of the slit from the sample in mm
    dtheta = 0.5 * degree  % integral angular width of the Bragg peak 
  end
      
  methods
    
    
    function psi = SchulzDefousingKernel(mu_t)
      psi.mu_t = mu_t;
    end
    
    
    function value = eval(psi,t)
      % evaluate the kernel function at nodes t = cos(alpha)

      alpha = acos(t);
      
      tau =  psi.dtheta/sqrt(2*pi);
      a  = (psi.r./psi.d) .* cos(psi.theta) .* tan(alpha);
      u1 = (a + psi.w/2) ./ (tau*sqrt(2));
      u2 = (a - psi.w/2) ./ (tau*sqrt(2));
      
      t1 = tau .* sqrt(2) ./ (2*a.*erf(psi.w/(2*tau*sqrt(2))));
      t2 = u1 .* erf(u1);
      t3 = u2 .* erf(u2);
      t4 = exp(-u1.^2)./sqrt(pi);
      t5 = exp(-u2.^2)./sqrt(pi);
      
      value = 1./(t1 .* (t2 - t3 + t4 - t5));
      
      % absorbtion correction
      %value  = value .* (1-exp(-2*psi.mu_t./sin(psi.theta))) ./ ...
      %  (1-exp(-2*psi.mu_t./sin(psi.theta)./cos(alpha)));
      
    end
     
    function plot(psi,varargin)
      plot@S2Kernel(psi,'omega',linspace(0.01,85*degree,1000),varargin{:});
      xlim([0,90])
    end
    
    
  end
  
end