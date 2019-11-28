function M = rank1prod(v1,v2,varargin)
% pointwise inner product
%
% Syntax
%   d = dot(v1,v2)
%   d = dot(v1,v2,'antipodal')
%
% Input
%  v1, v2 - @vector3d
%
% Options
%  antipodal - consider v1, v2 as axes
%
% Output
%  d - double

M = [[v1.x .* v2.x  v1.x .* v2.y   v1.x .* v2.z];...
  [v1.y .* v2.x  v1.y .* v2.y   v1.y .* v2.z];...
  [v1.z .* v2.x  v1.z .* v2.y   v1.z .* v2.z]];