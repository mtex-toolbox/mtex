function [xOut,yOut] = proxTV(xIn,yIn,lambda,varargin)

% compute geodetic distance
mu = angle(xIn,yIn,varargin{:}) * sqrt(2)/(2*lambda);

% 
t = 1 ./ (2*mu);
t(mu<=1) = 0.5;

% 
xOut = geodesic(xIn,yIn,t,varargin{:});
yOut = geodesic(xIn,yIn,1-t,varargin{:});
