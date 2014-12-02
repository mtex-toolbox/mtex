function varargout = unique(q,varargin)
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

[varargout{1:nargout}] = cunion(q,@(a,b) eq(a,b,varargin{:}));
