function sigma = deviatoricStress(sigma,varargin)
% deviatoric stress
%
% Syntax
%
%   S = deviatoricStress(sigma);
%
% Input
%  sigma - @stressTensor
%
% Output
%  s - @stressTensor
%


p = meanStress(sigma);

sigma.M(1,1,:) = sigma.M(1,1,:) - p;
sigma.M(2,2,:) = sigma.M(2,2,:) - p;
sigma.M(3,3,:) = sigma.M(3,3,:) - p;

