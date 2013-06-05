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

q = cunion(q,@(a,b) eq(a,b,varargin{:}));
