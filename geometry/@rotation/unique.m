function [r,ir,iu] = unique(r,varargin)
% disjoint list of rotations
%
% Syntax
%   u = unique(r)
%   u = unique(r,'tolerance',0.01)
%   [u,ir,iu] = unique(r)
%
% Input
%  r   - @rotation
%  tol - double (default 1e-3)
%
% Output
%  u - @rotation
%  ir - index such that u = r(ir)
%  iu - index such that r = u(iu)
%
% Flags
%  stable - prevent sorting
%
% See also
% unique
%

a = r.a(:);
b = r.b(:);
c = r.c(:);
d = r.d(:);
i = r.i(:);

abcd = [a.^2,b.^2,c.^2,d.^2,a.*b,a.*c,a.*d,b.*c,b.*d,c.*d,i];

tol = get_option(varargin,'tolerance',1e-3);

% in case it should not be sorted
if check_option(varargin,'stable')
  varargin = {'stable'};
else
  varargin= {};
end

% for some reason this is quite slow
% [~,m,n] = uniquetol(1+abcd,tol,'ByRows',true);
[~,ir,iu] = uniquetol(abcd,tol,'ByRows',true,'DataScale',1,varargin{:});
%[~,ir,iu] = unique(round(abcd./tol),'rows',varargin{:});

% remove duplicated points
r.a = a(ir);
r.b = b(ir);
r.c = c(ir);
r.d = d(ir);
r.i = i(ir);
