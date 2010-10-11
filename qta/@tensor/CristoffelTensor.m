function C = CristoffelTensor(E,v)
% Cristoffel tensor of an elasticity tensor for a given direction
%
%% Desription
% Formular: C_jk = E_ijkl v_j v_l
%
%% Input
%  E - elaticity @tensor
%  v - list of @vector3d
%
%% Output
%  C - Cristoffel @tensor
%
%% See also
% tensor/quadric tensor/rotate

% compute tensor products
C = EinsteinSum(E,[1 -1 2 -2],v,-1,v,-2);

C.name = 'Cristoffel';
