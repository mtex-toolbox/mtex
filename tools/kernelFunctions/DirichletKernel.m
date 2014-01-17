classdef DirichletKernel < kernel
% the Dirichlet kernel

  methods
    
    function psi = DirichletKernel(N)
      
      psi.A = ones(N+1,1);
      
    end
  
    function c = char(psi)
      c = ['Dirichlet, halfwidth ' ...
        xnum2str(psi.halfwidth/degree) mtexdegchar];
    end
    
    function value = K(psi,co2)
      % the kernel function on SO(3)
      value   =  ((2*psi.bandwith + 1)*sin((2*psi.bandwith+3)*acos(co2)) - ...
      (2*psi.bandwith+3)*sin((2*psi.bandwith + 1)*acos(co2))) ...
      ./ (4*sin(acos(co2).^3));
    end
  
    function value = RK(psi,t)
      % the radon transformed kernel function at 
      value  = (1+psi.kappa) * ((1+t)/2).^psi.kappa;
    end
        
  end
  
end
