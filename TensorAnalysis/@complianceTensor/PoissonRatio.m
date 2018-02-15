function nu = PoissonRatio(C,x,y)
% computes the Poisson ratio of an elasticity tensor
%
% Input
%  C - elastic @stiffnessTensor
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
  
  nu = S2FunHarmonicSym.quadrature(@(v) PoissonRatio(C,v,y),'bandwidth',4,C.CS);
    
elseif nargin <= 2 || isempty(y)

  nu = S2FunHarmonicSym.quadrature(@(v) PoissonRatio(C,x,v),'bandwidth',4,C.CS);
    
else

  % compute the complience
  S = inv(C);

  % compute tensor product
  nu = -double(EinsteinSum(S,[-1 -2 -3 -4],x,-1,x,-2,y,-3,y,-4)) ./ ...
    double(EinsteinSum(S,[-1 -2 -3 -4],x,-1,x,-2,x,-3,x,-4));
end
