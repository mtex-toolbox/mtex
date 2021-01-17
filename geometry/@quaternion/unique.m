function [q,iq,iu] = unique(q,varargin)
% disjoint list of quaternions
%
% Syntax
%   u = unique(q)
%   u = unique(q,'tolerance',tol)
%   [u,iq,iu] = unique(q)
%
% Input
%  q   - @quaternion
%  tol - double (default 1e-3)
%
% Output
%  u - @quaternion
%  iq - index such that u = q(iq)
%  iu - index such that q = u(iu)
%
% Flags
%  stable - prevent sorting
%
% See also
% unique
%

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

% in case it should not be sorted
tol = get_option(varargin,'tolerance',1e-3);
if check_option(varargin,'stable')
  [~,iq,iu] = unique(round(abcd ./ tol),'rows','stable');
else
  [~,iq,iu] = uniquetol(abcd,tol,'ByRows',true,'DataScale',1);
end

% remove duplicated points
q.a = q.a(iq);
q.b = q.b(iq);
q.c = q.c(iq);
q.d = q.d(iq);
