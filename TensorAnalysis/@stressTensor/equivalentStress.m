function s = equivalentStress(sigma,varargin)
% von Mises equivalent stress
%
% Input
%  sigma - @stressTensor
%
% Output
%  s - double
%

M = sigma.M;

s = sqrt(M(1,1,:).^2 + M(2,2,:).^2 + M(3,3,:).^2 ...
  - M(1,1,:).*M(2,2,:) - M(2,2,:).*M(3,3,:)- M(1,1,:).*M(3,3,:) ...
  + 3*(M(1,2).^2 + M(1,3).^2 + M(2,3).^2 ));

% this is acutally the same as
% s = sigma.deviatoricStress
% s = sqrt(3/2)*norm(s)