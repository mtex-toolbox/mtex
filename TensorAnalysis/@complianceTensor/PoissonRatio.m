function nu = PoissonRatio(S,x,y)
% computes the Poisson ratio of an elasticity tensor
%
% Input
%  S - elastic @complianceTensor
%  x - @vector3d
%  y - @vector3d
%
% Output
%  nu - Poisson ratio in directions x and y
%
% Remarks
% 
% $$\nu = \frac{-S_{ijkl} x_i x_j y_k y_l}{S_{mnop} x_m x_n x_o x_p}$$ 
%

% generate a function if required
if nargin == 1 || isempty(x)
  
  nu = S2FunHarmonicSym.quadrature(@(v) PoissonRatio(S,v,y),'bandwidth',4,S.CS);
    
elseif nargin <= 2 || isempty(y)

  nu = S2FunHarmonicSym.quadrature(@(v) PoissonRatio(S,x,v),'bandwidth',4,S.CS);
    
else

  % compute tensor product
  nu = -double(EinsteinSum(S,[-1 -2 -3 -4],x,-1,x,-2,y,-3,y,-4)) ./ ...
    double(EinsteinSum(S,[-1 -2 -3 -4],x,-1,x,-2,x,-3,x,-4));
  
end
