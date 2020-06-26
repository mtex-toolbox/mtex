function d = dot(v1,v2,varargin)
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
%  antipodal       - consider v1, v2 as axes
%  ignoreAntipodal - do not consider axes
%
% Output
%  d - double

% compute dot product
xx = v1.x .* v2.x;
yy = v1.y .* v2.y;
zz = v1.z .* v2.z;
d = xx + yy + zz;

% 
if (check_option(varargin,'antipodal') || v1.antipodal || v2.antipodal) && ...
    ~check_option(varargin,'noAntipodal')
  d = abs(d);
end
