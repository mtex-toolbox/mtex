function epsilon = CauchyStrain(F)
% Cauchy strain or small strain
%
% Syntax
%   epsilon = CauchyStrain(F)
%
% Input
%  F - @deformationTensor
%
% Output
%  epsilon - @strainTensor
%

epsilon = strainTensor(F.sym - eye(3));
