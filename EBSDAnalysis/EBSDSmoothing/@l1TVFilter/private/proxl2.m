function x = proxl2(x,v,lambda,varargin)
%
% Input
%  x 
%  v - reference orientation
%
% Output
%  x - 
%

t = lambda ./ (1+lambda);

x = geodesic(x,v,t,varargin{:});
