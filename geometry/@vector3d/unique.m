function [v,ind] = unique(v,varargin)
% disjoint list of vectors
%
%% Syntax
%  v = symeq(v,<options>) - 
%
%% Input
%  v - @vector3d
%
%% Output
%  v - @vector3d

[v,ind] = cunion(v,@(a,b) eq(a,b,varargin{:}));

v = delete_option(v,'INDEXED');
