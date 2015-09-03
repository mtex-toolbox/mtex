function [ad,omega] = calcAngleDistribution(oR,varargin)
% compute the angle distribution of a uniform ODF for a crystal symmetry
%
% Syntax
%   [ad,omega] = calcAngleDistribution(oR)
%   [ad,omega] = calcAngleDistribution(oR,omega)
%
% Input
%  oR    - @orientationRegion
%  omega - angle
%
% Ouput
%  ad - angle distribution
%  omega - angles
%

if isempty(varargin)
  omega = linspace(0,oR.maxAngle,300);
else
  % restrict omega
  omega = varargin{1};
  omega = omega(omega < oR.maxAngle + 1e-8);
end

ad = zeros(size(omega));
S2G = equispacedS2Grid('resolution',0.5*degree);
sR = oR.axisSector;
S2G = S2G.subSet(sR.checkInside(S2G));
for i = 1:length(omega)
  sR = oR.axisSector(omega(i));
  ad(i) = 2 * volume(sR,S2G) * sin(omega(i)/2)^2;
end

ad = ad ./ mean(ad);