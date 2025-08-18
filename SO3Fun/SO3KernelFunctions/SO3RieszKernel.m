classdef SO3RieszKernel < SO3Kernel
% The Riez potential is defined as
% 
% |q1-q2|^2 = <q1-q2,q1-q2> = |q1|^2 + |q2|^2 - 2<q1,q1> = 2 - 2 cos w/2
% 
% We can define the Riesz kernel $\psi_{s}$ depending on a parameter 
% $s$ by 
%
% $$ \psi_{s}(q_1,q_2) = \frac{1}{\lVert q_1 - q_2 \rVert^s}$$.
%
% Syntax
%   psi = SO3RieszKernel(s)
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
    
  function psi = SO3RieszKernel(s,varargin)

    if nargin == 1, psi.s = s; end
    
    % extract bandwidth
    L = get_option(varargin,'bandwidth',1000);

    acc = getMTEXpref('FFTAccuracy');
    setMTEXpref('FFTAccuracy',1e-10)
    psi.A = calcFourier(psi,1000);
    setMTEXpref('FFTAccuracy',acc)

  end
  
  function c = char(psi)
    c = ['Riesz kernel, s = ' xnum2str(psi.s)];
  end
  
  function value = eval(psi,co2)    
    
    value = 1./(((1 - co2)./2).^(psi.s / 2));

  end

  function value = grad(psi,co2)    

    if nargin == 2
      value = -psi.s/8 * sqrt(1-co2.^2) .* 1./(((1 - co2)./2).^(psi.s / 2 +1));
      %value = 2 * psi.C * psi.kappa *co2.^(2*psi.kappa-1);
    else      
      value = SO3KernelHandle(@(co2) -psi.s/8 * sqrt(1-co2.^2) .* 1./(((1 - co2)./2).^(psi.s / 2 +1)));
    end

  end
  
end

end
