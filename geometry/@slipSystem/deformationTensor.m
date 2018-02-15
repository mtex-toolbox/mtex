function eps = deformationTensor(sS)
% deformation tensor
%
% Syntax
%   eps = deformationTensor(sS)
%
% Input
%  sS - list of @slipSystem
%
% Output
%  eps - deformationTensor
%

eps = EinsteinSum(tensor(sS.b.normalize),1,sS.n.normalize,2);
