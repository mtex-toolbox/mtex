function E = ChristoffelTensor(C,n)
% Christoffel tensor of an elasticity tensor for a given direction
%
%% Desription
% Formular: E_jk = C_ijkl n_j n_l
%
%% Input
%  C - elatic stiffness @tensor
%  x - list of @vector3d
%
%% Output
%  E - Christoffel @tensor
%
%% See also
% tensor/directionalMagnitude tensor/rotate

% compute tensor products
E = EinsteinSum(C,[1 -1 2 -2],n,-1,n,-2);

E = set(E,'name','Cristoffel');
