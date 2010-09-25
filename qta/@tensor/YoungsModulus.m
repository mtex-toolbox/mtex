function Y = YoungsModulus(E,v)
% Young's modulus for an elasticity tensor
%
%% Input
%  E - elasticity @tensor
%  v - list of @vector3d
%
%% Output
%  Y - Youngs modulus
%
%% See also

% inverse the Elasticity tensor
S = inv(E);


% compute quadric
Y = 1./quadric(S,v);

