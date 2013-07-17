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

% find duplicates points
[ignore,m,n] = unique(round([q.a(:),q.b(:),q.c(:),q.d(:)]*1e7),'rows'); %#ok<ASGLU>

% remove duplicated points
q.a = q.a(m);
q.b = q.b(m);
q.c = q.c(m);
q.d = q.d(m);
