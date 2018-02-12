function b = eq(dS1,dS2,varargin)
% ? sS1 == sS2
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

if dS1.CS ~= dS2.CS || ...
    (length(dS1)>1 && length(dS2)>1 && any(size(dS2)~=size(dS1)))
  b = false;
  return
end

b = dS1.b == dS2.b & dS1.l == dS2.l;
