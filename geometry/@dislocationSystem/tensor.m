function alpha = tensor(dS)
% tensor representation of a dislocation system
%
% Syntax
%   alpha = tensor(dS)
%
% Input
%  dS - list of @dislocationSystem
%
% Output
%  alpha - list of @tensor
%

alpha = dislocationDensityTensor(dyad(dS.b, dS.l.normalize),'unit','au');
