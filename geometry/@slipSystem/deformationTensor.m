function eps = deformationTensor(sS)
% deformation tensor
%
% Syntax
%
%   SF = SchmidFactor(sS,v)
%   SF = SchmidFactor(sS,sigma)
%
% Input
%  sS - list of @slipSystem
%  v  - @vector3d - list of tension direction
%  sigma - stress @tensor
%
% Output
%  SF - size(sS) x size(sigma) matrix of Schmid factors
%

eps = EinsteinSum(tensor(sS.b.normalize),1,sS.n.normalize,2);
