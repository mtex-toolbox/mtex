function [r,m,n] = unique(r,varargin)
% disjoint list of rotations
%
% Syntax
%   r = unique(r)
%
% Input
%  r - @rotation
%
% Output
%  r - @rotation

% split according to inversion

a = r.a(:);
b = r.b(:);
c = r.c(:);
d = r.d(:);

abcd = [a.^2,b.^2,c.^2,d.^2,a.*b,a.*c,a.*d,b.*c,b.*d,c.*d,r.i(:)];

[ignore,m,n] = unique(round(abcd*1e4),'rows'); %#ok<ASGLU>

% remove duplicated points
r.a = r.a(m);
r.b = r.b(m);
r.c = r.c(m);
r.d = r.d(m);
r.i = r.i(m);
