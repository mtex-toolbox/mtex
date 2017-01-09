function E = shearModulus(C,h,u)
% shear modulus for an elasticity tensor
%
% Description
%
% $$G = \frac{1}{4 S_{ijkl} h_i u_j h_k u_l}$$
%
% Input
%  C - elastic stiffness @tensor
%  h - shear plane @vector3d
%  u - shear direction @vector3d
%
% Output
%  E - shear modulus
%
% See also
% tensor/YoungsModulus tensor/volumeCompressibility tensor/ChristoffelTensor

% prepare to return a spherical function
generateFun = 0;
if nargin == 1 || isempty(h)
  h = equispacedS2Grid('points',10000);
  generateFun = 1;
end
if nargin <= 2 || isempty(u)
  u = equispacedS2Grid('points',10000);
  generateFun = 2;
end

% compute the compliance tensor
S = inv(C);

% compute directional magnitude
E = 0.25./matrix(EinsteinSum(S,[-1 -2 -3 -4],h,-1,u,-2,h,-3,u,-4));

% generate a function if required
if generateFun == 1
  E = sphFunTri(h,E);
else
  E = sphFunTri(u,E);
end  
