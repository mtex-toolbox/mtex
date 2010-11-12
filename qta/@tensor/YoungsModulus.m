function E = YoungsModulus(C,x)
% Young's modulus for an elasticity tensor
%
%% Description
%
% formula: E = 1/(S_ijkl x_i x_j x_k x_l)
%
%% Input
%  C - elastic stiffness @tensor
%  x - list of @vector3d
%
%% Output
%  E - Youngs modulus
%
%% See also

% compute the compliance tensor
S = inv(C);

% compute quadric
E = 1./quadric(S,x);
