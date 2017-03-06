function nu = PoissonRatio(C,x,y)
% computes the Poisson ratio of an elasticity tensor
%
% Input
%  C - elastic compliance @tensor
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

% prepare to return a spherical function
generateFun = 0;
if nargin == 1 || isempty(x)
  x = equispacedS2Grid('points',10000);
  generateFun = 1;
end
if nargin <= 2 || isempty(y)
  y = equispacedS2Grid('points',10000);
  generateFun = 2;
end

% compute the complience
S = inv(C);

% compute tensor product
nu = -double(EinsteinSum(S,[-1 -2 -3 -4],x,-1,x,-2,y,-3,y,-4)) ./ ...
    double(EinsteinSum(S,[-1 -2 -3 -4],x,-1,x,-2,x,-3,x,-4));

% generate a function if required
if generateFun == 1
  nu = sphFunTri(x,nu);
elseif generateFun == 2
  nu = sphFunTri(y,nu);
end  
