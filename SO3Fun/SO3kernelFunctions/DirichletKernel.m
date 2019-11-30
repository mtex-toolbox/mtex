classdef DirichletKernel < kernel
%the Dirichlet kernel in the orientation space
%
% Syntax
%   psi = DirichletKernel(bandwidth)

  methods
    
    function psi = DirichletKernel(N)
      
      psi.A = 2.*(0:N)+1;
            
    end
  
    function c = char(psi)
      c = ['Dirichlet, bandwidth ' num2str(psi.bandwidth)];
    end
    
    function value = K(psi,co2)
      % the kernel function on SO(3)
      
      N = psi.bandwidth;
      
      ind = co2 > 1-eps;
       value(ind) = (1+N)*(1+2*N)*(3+2*N)/3;
       
       value(~ind) = csc(acos(co2)).^3 .* ...
         ((3+2*N)*sin((1+2*N)*acos(co2)) - ...
         (1+2*N)*sin((3+2*N)*acos(co2)))./4;
       
    end
    
    function hw = halfwidth(psi)
      hw = fminbnd(@(omega) (psi.K(1)-2*psi.K(cos(omega/2))).^2,0,2*pi/psi.bandwidth);
    end
    
    
    
  end
  
end
