function a = angle(m1,m2,varargin)
% angle between two Miller indece
%% Syntax
%  a = angle(m1,m2)
%
%% Input
%  m1,m2 - @Miller
%
%% Output
%  a - angle

a = real(acos(dot(m1,m2,varargin{:})));
