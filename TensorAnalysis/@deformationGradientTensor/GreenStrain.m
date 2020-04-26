function E = GreenStrain(F)
%
% Syntax
%   E = GreenStrain(F)
%
% Input
%  F - @deformationTensor
%
% Output
%  epsilon - @strainTensor
%

E = 0.5 * strainTensor(F * F' - tensor(eye(3),'rank',2));
