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
i = r.i(:);

abcd = [a.^2,b.^2,c.^2,d.^2,a.*b,a.*c,a.*d,b.*c,b.*d,c.*d,i];

[ignore,m,n] = unique(round(abcd*1e4),'rows'); %#ok<ASGLU>

% remove duplicated points
r.a = a(m);
r.b = b(m);
r.c = c(m);
r.d = d(m);
r.i = i(m);
