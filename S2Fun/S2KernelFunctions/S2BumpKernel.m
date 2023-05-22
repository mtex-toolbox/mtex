classdef S2BumpKernel < S2Kernel
% The spherical Bump kernel is a radial symmetric kernel function depending
% on the halfwidth $r\in (0,pi)$. 
% The function value is 0, if the angle is greater then the halfwidth $r$. 
% Otherwise it is 1.
%
% Syntax
%   psi = S2BumpKernel(10*degree)
%   psi = S2BumpKernel('halfwidth',10*degree)
%
% Options
%  halfwidth - angle at which the kernel function has reduced to half its peak value  
%  bandwidth - harmonic degree
%
% See also
% S2Kernel

  properties
    halfwidth % halfwidth of the kernel
  end
    
  methods
    
    
    function psi = S2BumpKernel(varargin)
    
      % extract parameter and halfwidth
      if nargin > 0 && isnumeric(varargin{1})
        psi.halfwidth = varargin{1};
      else
        psi.halfwidth = get_option(varargin,'halfwidth',10*degree);
      end
      
      % extract bandwidth
      L = get_option(varargin,'bandwidth',2000);
            
      % compute Legendre coefficients
      % TODO: calcFourier does not work for Bump kernel
      warning('The Fourier coefficients are to less')
      psi.A = calcFourier(psi,L,psi.halfwidth);
      %psi.A = nan(1,L+1);
      
      %psi.A = psi.cutA;
    end
    
    
    function value = eval(psi,t)
      % evaluate the kernel function at nodes x

      value  = double(t > cos(psi.halfwidth));
      
    end
    
  end
  
end