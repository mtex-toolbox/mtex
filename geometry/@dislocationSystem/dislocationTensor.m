function alpha = dislocationTensor(dS)
% dislocation tensor
%
% Syntax
%   alpha = dislocationTensor(dS)
%
% Input
%  dS - list of @dislocationSystem
%
% Output
%  alpha - list of @dislocationTensor
%

alpha = dislocationTensor(dyad(dS.b, dS.l.normalize)); 

alpha = reshape(alpha,size(dS));
