classdef SO3RieszKernel < SO3Kernel
% The Riez potential is defined as
% 
% |q1-q2|^2 = <q1-q2,q1-q2> = |q1|^2 + |q2|^2 - 2<q1,q1> = 2 - 2 cos w/2
% 
%
% 
% $$ K(t) = \frac{B(\frac32,\frac12)}{B(\frac32,\kappa+\frac12)}\,t^{2\kappa}$$ 
% 
% for $t\in[0,1]$, where $B$ denotes the Beta function. The de la Vallee 
% Poussin kernel additionaly has the unique property that for
% a given halfwidth it can be described exactly by a finite number of 
% Fourier coefficients. This kernel is recommended for Texture analysis as 
% it is always positive in orientation space and there is no truncation 
% error in Fourier space.
%
% Hence we can define the de la Vallee Poussin kernel $\psi_{\kappa}$ 
% depending on a parameter $\kappa \in \mathbb N \setminus \{0\}$ by its 
% finite Chebyshev expansion
%
% $$ \psi_{s}(q_1,q_2) = \frac{1}{\lVert q_1  q_2 \rVert^s}$$.
%
% Syntax
%   psi = SO3RieszKernel(s)
%   psi = SO3DeLaValleePoussinKernel('halfwidth',5*degree)
%
% Input
%  s - exponent
%
% See also
% SO3Kernel

properties
  s = 1
end
      
methods
    
  function psi = SO3RieszKernel(s)

    if nargin == 1, psi.s = s; end

  end
  
  function c = char(psi)
    c = ['Riesz kernel, s = ' xnum2str(psi.s)];
  end
  
  function value = eval(psi,co2)    
    
    value = 1./(((1 - co2)./2).^(psi.s / 2));

  end
  
end

end
