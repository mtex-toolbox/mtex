classdef SO3RestrictedDistanceKernel < SO3Kernel
% The rotational restricted distance kernel is defined by 
% 
% $$ K(t) = -\sqrt{8}\sin(\acos(t))$$ 
% 
% for $t\in[0,1]$. 
% This kernel is negative and describes the distance between two given
% orientations, by K.eval(angle(R,Q)).
% It is used in the compactify method to ensure that the points repel each 
% other and do not overlap.
%
% Syntax
%   psi = SO3RestrictedDistanceKernel(bw)
%
% Input
%  bw - bandwidth
%
% Output
%  psi - @SO3Kernel
%
% See also
% SO3Kernel SO3Fun/compactify



   
  methods
    
    
    function psi = SO3RestrictedDistanceKernel(bw)
    
      % extract parameter and halfwidth
      if nargin == 0 
        bw = getMTEXpref('maxSO3Bandwidth');
      end

      n = (0:bw);
      psi.A = 16*sqrt(2)/pi./((2*n-1).*(2*n+1).*(2*n+3));
           
     end
    
    
    % function value = eval(psi,t)
    %   % evaluate the kernel function at nodes x
    % 
    %   if isa(t,'rotation'), t = cos(angle(t)); end
    % 
    %   value  = -sqrt(8)*sin(acos(t)) ;
    % 
    % end

    
    
    function c = char(psi)
      c = ['restricted distance kernel, bandwidth ' xnum2str(psi.bandwidth)];
    end
        
  end
  
end