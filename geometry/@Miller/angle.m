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

m1 = symmetrice(m1,varargin{:});

a = min(real(acos(dot(m1,m2)./norm(m1)./norm(m2))),[],2);
