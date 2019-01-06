function x = proxDist(x,v,lambda,varargin)
%
% Input
%  x 
%  v - reference orientation
%
% Output
%  x - 
%

mu = angle(v,x) * sqrt(2) ./ lambda;

t = 1 ./ (2*mu);
t(mu<=1) = 0.5;

x = geodesic(x,v,t,varargin{:});

