function x = proxl1(x,v,lambda,varargin)
%
% Input
%  x 
%  v - reference orientation
%
% Output
%  x - 
%

t = lambda ./ angle(v,x);
t = min(t,1);

x = geodesic(x,v,t,varargin{:});
