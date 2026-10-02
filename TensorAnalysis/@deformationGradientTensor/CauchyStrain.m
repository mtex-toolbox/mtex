function epsilon = CauchyStrain(F)
% Cauchy strain or small strain
%
% Syntax
%   epsilon = CauchyStrain(F)
%
% Input
%  F - @deformationGradientTensor
%
% Output
%  epsilon - @strainTensor
%

epsilon = strainTensor(F.sym - tensor(eye(3),'rank',2));
