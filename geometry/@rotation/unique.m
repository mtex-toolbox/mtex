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


a = r.a(:); b = r.b(:); c = r.c(:); d = r.d(:); i = r.i(:);

if length(r) < 1000 && ~check_option(varargin,'tolerance')
  
  abcd = [a.^2,b.^2,c.^2,d.^2,a.*b,a.*c,a.*d,b.*c,b.*d,c.*d, i(:)];

  tol = get_option(varargin,'tolerance',1e-3);

  % in case it should not be sorted
  if check_option(varargin,'stable')
    [~,ir,iu] = unique(round(abcd./tol),'rows','stable');
  else
    [~,ir,iu] = uniquetol(abcd,tol,'ByRows',true,'DataScale',1);
  end
  
else % faster but less accurate
  

  tol = get_option(varargin,'tolerance',5*degree);

  % ensure upper hemisphere
  ind = d < 0;
  a(ind) = -a(ind); b(ind) = -b(ind);
  c(ind) = -c(ind); d(ind) = -d(ind);
  
  [~,ir,iu] = uniquetol([a,b,c,d,i],tol / 100 / degree, ...
    'ByRows',true,'DataScale',1);

end

% remove duplicated points
r.a = a(ir);
r.b = b(ir);
r.c = c(ir);
r.d = d(ir);
r.i = i(ir);

