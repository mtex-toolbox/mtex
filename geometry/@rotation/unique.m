function [r,m,n] = unique(r,varargin)
% disjoint list of rotations
%
% Syntax
%   r = unique(r)
%   r = unique(r,'tolerance',0.01)
%   [r,m,n] = unique(r)
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

tol = get_option(varargin,'tolerance',1e-3);

try
  [~,m,n] = uniquetol(1+abcd,tol,'ByRows',true);
catch
  [~,m,n] = unique(round(abcd./tol),'rows');
end

% remove duplicated points
r.a = a(m);
r.b = b(m);
r.c = c(m);
r.d = d(m);
r.i = i(m);
