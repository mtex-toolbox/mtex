classdef S2BumpKernel < S2Kernel
% the spherical bump kernel
%
% Syntax
%
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
      L = get_option(varargin,'bandwidth',128);
            
      % compute Legendre coefficients
      psi.A = nan(1,L+1);
      
      %psi.A = psi.cutA;
    end
    
    
    function value = eval(psi,t)
      % evaluate the kernel function at nodes x

      value  = double(t > cos(psi.halfwidth));
      
    end
    
  end
  
end