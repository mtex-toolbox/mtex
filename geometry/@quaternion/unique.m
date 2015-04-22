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

% q = cunion(q,@(a,b) eq(a,b,varargin{:}));

% maybe there is nothing to do
if length(q) == 1 && nargout <= 1, return; end

a = q.a(:);
b = q.b(:);
c = q.c(:);
d = q.d(:);

% find duplicates points
% [ignore,m,n] = unique(round([a b c d]*1e7),'rows'); %#ok<ASGLU>
% q == -q;
if check_option(varargin,'antipodal')
  abcd = [a.^2,b.^2,c.^2,d.^2,a.*b,a.*c,a.*d,b.*c,b.*d,c.*d];
else
  abcd = [a,b,c,d];
end

[ignore,m,n] = unique(round(abcd*1e7),'rows'); %#ok<ASGLU>

% remove duplicated points
q.a = q.a(m);
q.b = q.b(m);
q.c = q.c(m);
q.d = q.d(m);
