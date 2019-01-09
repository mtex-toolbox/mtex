function x = proxDist(x,v,lambda,varargin)
%
% Input
%  x 
%  v - reference orientation
%
% Output
%  x - 
%

t = lambda ./ angle(v,x);
t = min(t,0.5);

x = geodesic(x,v,t,varargin{:});
