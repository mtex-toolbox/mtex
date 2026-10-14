function E = GreenStrain(F)
% Green-Lagrange strain tensor of a deformation gradient
%
% The Green-Lagrange strain is E = (F' * F - I) / 2.
%
% Syntax
%
%   E = GreenStrain(F)
%
% Input
%  F - @deformationGradientTensor
%
% Output
%  E - @strainTensor

E = 0.5 * strainTensor(F' * F - tensor(eye(3),'rank',2));
