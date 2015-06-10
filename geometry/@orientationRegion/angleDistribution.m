function [ad,omega] = angleDistribution(oR,varargin)
% compute the angle distribution of a uniform ODF for a crystal symmetry
%
% Syntax
%   [ad,omega] = angleDistribution(oR)
%   [ad,omega] = angleDistribution(oR,omega)
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
for i = 1:length(omega)
  sR = oR.axisSector(omega(i));
  ad(i) = sR.area * sin(omega(i)/2)^2;
end
