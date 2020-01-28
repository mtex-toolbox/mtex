function d = dot(g1,g2,varargin)
% inner product of quaternions g1 and g2
%
% Input
%  q1, q2 - @quaternion
%
% Output
%  d - double
%

d = g1.a .* g2.a + g1.b .* g2.b + g1.c .* g2.c + g1.d .* g2.d;
