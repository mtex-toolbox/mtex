function A = dislocationTensor(dS)
% dislocation tensor
%
% Syntax
%   kappa = dislocationTensor(dS)
%
% Input
%  dS - list of @dislocationSystem
%
% Output
%  kappa - list of dislocation tensors
%

A = EinsteinSum(tensor(dS.b.normalize),1,dS.l.normalize,2); ...
%  -0.5*diag(EinsteinSum(tensor(dS.b.normalize),-1,dS.l.normalize,-1));
