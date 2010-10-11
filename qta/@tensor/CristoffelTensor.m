function T = CristoffelTensor(E,v)
% Cristoffel tensor of an elasticity tensor for a given direction
%
%% Desription
% Formular: T_jk = E_ijkl v_j v_l
%
%% Input
%  E - elaticity @tensor
%  v - list of @vector3d
%
%% Output
%  T - Cristoffel @tensor
%
%% See also
% tensor/quadric tensor/rotate

% convert directions to double
d = double(v);

% compute tensor products
T = mtimesT(E,2,d,[3 4]);
T = mtimesT(T,3,d,[3 4]);

T.name = 'Cristoffel';
