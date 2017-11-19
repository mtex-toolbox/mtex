function [q,m,n] = unique(q,varargin)
% disjoint list of quaternions
%
% Syntax
%   q = unique(q)
%
% Input
%  q - @quaternion
%
% Output
%  q - @quaternion

% maybe there is nothing to do
if length(q) == 1 && nargout <= 1, return; end

a = q.a(:);
b = q.b(:);
c = q.c(:);
d = q.d(:);

% antipodal quaternions are just rotations
if check_option(varargin,'antipodal')
  abcd = [a.^2,b.^2,c.^2,d.^2,a.*b,a.*c,a.*d,b.*c,b.*d,c.*d];
else
  abcd = [a,b,c,d];
end

tol = get_option(varargin,'tolerance',1e-3);

try
  [~,m,n] = uniquetol(1+abcd,tol,'ByRows',true);
catch
  [~,m,n] = unique(round(abcd ./ tol),'rows');
end

% remove duplicated points
q.a = q.a(m);
q.b = q.b(m);
q.c = q.c(m);
q.d = q.d(m);
