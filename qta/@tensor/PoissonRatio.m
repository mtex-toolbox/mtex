function out = PoissonRatio(E,X,Y)
% computes the Poisson ratio of an elasticity tensor
%
%% Description
% formula: V = -S_ijkl X_i X_j Y_k Y_l / S_mnop X_m X_n X_o X_p 
%
%% Input
%  E - elasticity @tensor
%  X - @vector3d
%  Y - @vector3d
%
%% Output
%  out - Poisson ratio in directions X qnd Y
%

% compute the complience
S = inv(E);

% compute tensor product
out = -double(EinsteinSum(S,[-1 -2 -3 -4],X,-1,X,-2,Y,-3,Y,-4)) ./ ...
    double(EinsteinSum(S,[-1 -2 -3 -4],X,-1,X,-2,X,-3,X,-4));