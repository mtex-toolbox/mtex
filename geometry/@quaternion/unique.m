function q = unique(q,varargin)
% disjoint list of quaternions
%
%% Syntax
%  q = unique(q,<options>) - 
%
%% Input
%  q - @quaternion
%
%% Output
%  q - @quaternion

% q = cunion(q,@(a,b) eq(a,b,varargin{:}));

a = q.a(:);
b = q.b(:);
c = q.c(:);
d = q.d(:);

% find duplicates points
% [ignore,m,n] = unique(round([a b c d]*1e7),'rows'); %#ok<ASGLU>
% q == -q;
[ignore,m,n] = unique(round([a.^2,b.^2,c.^2,d.^2,a.*b,a.*c,a.*d,b.*c,b.*d,c.*d]*1e7),'rows'); %#ok<ASGLU>

% remove duplicated points
q.a = q.a(m);
q.b = q.b(m);
q.c = q.c(m);
q.d = q.d(m);
