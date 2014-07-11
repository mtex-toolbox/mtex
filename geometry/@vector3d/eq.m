function b = eq(v1,v2,varargin)
% ? v1 == v2
%
% Input
%  v1, v2 - @vector3d
%
% Output
%  b - boolean
%
% Options
%  antipodal - include antipodal symmetry
%

if length(v1)>1 && length(v2)>1 && any(size(v2)~=size(v1))
  b = false;
  return
end

b = isnull(dot(v1,v2,varargin{:}) - sqrt(dot(v1,v1)) .* sqrt(dot(v2,v2)));

