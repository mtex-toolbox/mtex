function b = eq(m1,m2,varargin)
% ? m1 == m2
%
%% Input
%  m1, m2 - @Miller
%
%% Output
%  b - boolean
%
%% Options
%  antipodal - include antipodal symmetry
%

b = isnull(angle(m1,m2,varargin{:}));
