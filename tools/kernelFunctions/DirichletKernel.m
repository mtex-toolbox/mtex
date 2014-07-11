classdef DirichletKernel < kernel
% the Dirichlet kernel

  methods
    
    function psi = DirichletKernel(N)
      
      psi.A = ones(N+1,1);
      
    end
  
    function c = char(psi)
      c = ['Dirichlet, bandwidth ' num2str(psi.bandwidth)];
    end
    
%     function value = K(psi,co2)
%       % the kernel function on SO(3)
%       value   =  ((2*psi.bandwidth + 1)*sin((2*psi.bandwidth+3)*acos(co2)) - ...
%       (2*psi.bandwidth+3)*sin((2*psi.bandwidth + 1)*acos(co2))) ...
%       ./ (4*sin(acos(co2).^3));
%     end
        
  end
  
end
