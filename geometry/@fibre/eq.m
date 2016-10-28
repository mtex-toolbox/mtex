function b = eq(f1,f2,varargin)
% ? sS1 == sS2
%
% Input
%  f1, f2 - @fibre
%
% Output
%  b - boolean
%
% Options
%  antipodal - include antipodal symmetry
%

if f1.CS ~= f2.CS || ...
    (length(f1)>1 && length(f2)>1 && any(size(f2)~=size(f1)))
  b = false;
  return
end

b = f1.h == f2.h & f1.r == f2.r;
