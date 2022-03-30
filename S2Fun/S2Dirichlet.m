classdef S2Dirichlet < S2Kernel
% the spherical Dirichlet or Christoffel-Darboux kernel
%
% Syntax
%
%   psi = S2Dirichlet(N)
%
% Input
%  N - polynomial degree / bandwidth
%
% See also
% S2Kernel

 
  properties (Dependent = true)
    halfwidth % halfwidth of the kernel
  end
    
  methods
    
    
    function psi = S2Dirichlet(N)
          
      psi.A = 2.*(0:N).'+1;
            
    end
    
    function hw = get.halfwidth(psi)
            
      hw = pi;
      
    end
        
  end
  
end