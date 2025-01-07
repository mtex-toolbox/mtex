classdef S1BumpKernel < S1Kernel
% The Bump kernel is a function depending on the halfwidth $r\in (0,pi)$. 
% The function value is 0, if the angle is greater then the halfwidth $r$. 
% Otherwise it is 1.
%
% Syntax
%   psi = S1BumpKernel(10*degree)
%   psi = S1BumpKernel('halfwidth',10*degree)
%
% Options
%  halfwidth - angle at which the kernel function has reduced to half its peak value  
%  bandwidth - harmonic degree
%

  properties
    halfwidth % halfwidth of the kernel
  end
    
  methods
    
    
    function psi = S1BumpKernel(varargin)
    
      % extract parameter and halfwidth
      if nargin > 0 && isnumeric(varargin{1})
        psi.halfwidth = varargin{1};
      else
        psi.halfwidth = get_option(varargin,'halfwidth',10*degree);
      end
      
      % extract bandwidth
      L = get_option(varargin,'bandwidth',5000);
            
      % compute Fourier coefficients
      psi.fhat = calcFourier(psi,'bandwidth',L);
      
    end
    
    
    function value = eval(psi,t)
      % evaluate the kernel function at nodes x

      value  = double( abs(mod(t+pi,2*pi)-pi) < psi.halfwidth);
      
    end

    function c = char(psi)
      c = ['Bump, halfwidth ' xnum2str(psi.halfwidth/degree) mtexdegchar];
    end
    
  end
  
end