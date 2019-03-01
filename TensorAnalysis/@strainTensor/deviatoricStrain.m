function epsilon = deviatoricStrain(epsilon,varargin)
% deviatoric strain tensor
%
% Input
%  epsilon - @strainTensor
%
% Output
%  e - @strainTensor
%

% the calculation essentially ensures that the trace of the resulting
% tensor is zero
p = trace(epsilon)./3;

epsilon.M(1,1,:) = epsilon.M(1,1,:) - p;
epsilon.M(2,2,:) = epsilon.M(2,2,:) - p;
epsilon.M(3,3,:) = epsilon.M(3,3,:) - p;

