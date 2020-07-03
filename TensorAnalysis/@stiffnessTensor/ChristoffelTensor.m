function E = ChristoffelTensor(C,n)
% Christoffel tensor of an elasticity tensor for a given direction
%
% Formula: E_jk = C_ijkl n_j n_l
%
% Input
%  C - elastic @stiffnessTensor
%  x - list of @vector3d
%
% Output
%  E - @ChristoffelTensor
%
% See also
% tensor/directionalMagnitude tensor/rotate

n = n.normalize;
E = ChristoffelTensor(EinsteinSum(C,[1 -1 2 -2],n,-1,n,-2));
