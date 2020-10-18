function nu = PoissonRatio(S,x,y)
% Poisson ratio of an elasticity tensor
%
% Syntax
%   nu = PoissonRatio(S,x,y)
%   nu = PoissonRatio(S) % isotropic case
%
% Input
%  S - elastic @complianceTensor
%  x - @vector3d tension direction
%  y - @vector3d perpendicular direction
%
% Output
%  nu - Poisson ratio
%
% Description
% 
% $$\nu = \frac{-S_{ijkl} x_i x_j y_k y_l}{S_{mnop} x_m x_n x_o x_p}$$ 
%


if nargin == 1  % isotrpoic theory
  
  S_iso_Voigt = mean(S,uniformODF(S.CS));
  nu = S_iso_Voigt.PoissonRatio(xvector,yvector);
  
  return
end

% generate a function if required
if nargin == 1 || isempty(x)
  
  nu = S2FunHarmonicSym.quadrature(@(v) PoissonRatio(S,v,y),'bandwidth',4,S.CS);
    
elseif nargin <= 2 || isempty(y)

  nu = S2FunHarmonicSym.quadrature(@(v) PoissonRatio(S,x,v),'bandwidth',4,S.CS);
    
else

  % compute tensor product
  nu = -EinsteinSum(S,[-1 -2 -3 -4],x,-1,x,-2,y,-3,y,-4) ./ ...
    EinsteinSum(S,[-1 -2 -3 -4],x,-1,x,-2,x,-3,x,-4);
  
end
