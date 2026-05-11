function r = subSet(r,varargin)
% indexing of rotation
%
% Syntax
%   subSet(q,ind) % 
%

r = subSet@quaternion(r,varargin{:});
r.i = r.i(varargin{:});

