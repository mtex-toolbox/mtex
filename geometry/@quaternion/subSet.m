function q = subSet(q,varargin)
% indexing of quaternions
%
% Syntax
%   subSet(q,ind) % 
%

q.a = q.a(varargin{:});
q.b = q.b(varargin{:});
q.c = q.c(varargin{:});
q.d = q.d(varargin{:});

