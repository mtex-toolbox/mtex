function b = eq(v1,v2,varargin)
% ? v1 == v2
%
%% Input
%  v1, v2 - @vector3d
%
%% Output
%  b - boolean
%
%% Options
%  antipodal - include antipodal symmetry
%

if numel(v1)>1 && numel(v2)>1 && any(size(v2)~=size(v1))
  b = false;
  return
end

b = isnull(angle(v1,v2,varargin{:}));
