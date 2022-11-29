classdef SO3DirichletKernel < SO3Kernel
% The Dirichlet kernel on SO(3) has the unique property of being a 
% convergent finite series in Fourier coefficients with an integral of one.
% This kernel is recommended for calculating physical properties as the 
% Fourier coefficients always have a value of one for a given bandwidth.
% 
% It is defined by its Chebyshev series
%
% $$ \psi_N(t) = \sum\limits_{n=0}^N (2n+1) \, \mathcal U_{2n}(t)$$.
%
% Syntax
%   psi = SO3DirichletKernel(35)
%
% Input
%  N - polynomial degree / bandwidth
%
% See also
% SO3Kernel


  methods
    
    function psi = SO3DirichletKernel(N)
      
      psi.A = 2.*(0:N)+1;
            
    end
  
    function c = char(psi)
      c = ['Dirichlet, bandwidth ' num2str(psi.bandwidth)];
    end
    
    function value = eval(psi,co2)
      % the kernel function on SO(3)
      
      N = psi.bandwidth;
      
      ind = co2 > 1-eps;
       value(ind) = (1+N)*(1+2*N)*(3+2*N)/3;
       
       value(~ind) = csc(acos(co2(~ind))).^3 .* ...
         ((3+2*N)*sin((1+2*N)*acos(co2(~ind))) - ...
         (1+2*N)*sin((3+2*N)*acos(co2(~ind))))./4;
       
    end
    
    function hw = halfwidth(psi)
      hw = fminbnd(@(omega) (psi.eval(1)-2*psi.eval(cos(omega/2))).^2,0,2*pi/psi.bandwidth);
    end

  end

end
