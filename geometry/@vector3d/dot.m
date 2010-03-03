function d = dot(v1,v2,varargin)
% pointwise inner product
%
%% Usage
% d = dot(v1,v2)
%
%% Input
%  v1, v2 - @vector3d
%
%% Options
%  antipodal - 
%
%% Output
%  double

d = v1.x .* v2.x + v1.y .* v2.y + v1.z .* v2.z;

if check_option(varargin,'antipodal')
  d = abs(d);
end
