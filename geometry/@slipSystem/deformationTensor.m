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

eps = dyad(sS.b.normalize,sS.n.normalize);