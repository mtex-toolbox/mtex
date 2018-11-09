function [fe,qe] = ellipsoid(E)
%
% Syntax
%   [fe,qe] = ellipsoid(E)
% 
% Input
%  E - @strainTensor
%
% Output
%

[fe,qe] = eig(E);
qe = sqrt(1+2*qe);