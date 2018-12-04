function sigmaEq = equivalentStress(sigma,varargin)
% von Mises equivalent stress
%
% Input
%  sigma - @stressTensor
%
% Output
%  s - double
%

s = sigma.deviatoricStress;
sigmaEq = sqrt(3/2 * s:s);

% the following code gives the same result
% is more efficient but less readable

% M = sigma.M;
% sigmaEq = sqrt(M(1,1,:).^2 + M(2,2,:).^2 + M(3,3,:).^2 ...
%   - M(1,1,:).*M(2,2,:) - M(2,2,:).*M(3,3,:)- M(1,1,:).*M(3,3,:) ...
%   + 3*(M(1,2).^2 + M(1,3).^2 + M(2,3).^2 ));
