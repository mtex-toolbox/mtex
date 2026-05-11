classdef S2RestrictedDistanceKernel < S2Kernel
% The spherical restricted distance kernel is defined by 
% 
% $$ K(t) = -2\sin(\frac{\acos(t)}{2})$$ 
% 
% for $t\in[0,1]$. 
% This kernel is negative and describes the distance between two given
% vector3d's, by K.eval(dot(v_1,v_2)).
% It is used in the compactify method to ensure that the points repel each 
% other and do not overlap.
%
% Syntax
%   psi = S2RestrictedDistanceKernel(bw)
%
% Input
%  bw - bandwidth
%
% Output
%  psi - @S2Kernel
%
% See also
% S2Kernel S2Fun/compactify



   
  methods
    
    
    function psi = S2RestrictedDistanceKernel(bw)
    
      % extract parameter and halfwidth
      if nargin == 0 
        bw = getMTEXpref('maxS2Bandwidth');
      end

      n = (0:bw).';
      psi.A = 4./((2*n-1).*(2*n+3));
           
     end
    
    
    % function value = eval(psi,t)
    %   % evaluate the kernel function at nodes x
    % 
    %   if isa(t,'vector3d'), t = dot(t,zvector); end
    % 
    %   value  = -2*sin(acos(t)/2);
    % 
    % end

    
    
    function c = char(psi)
      c = ['restricted distance kernel, bandwidth ' xnum2str(psi.bandwidth)];
    end
        
  end
  
end