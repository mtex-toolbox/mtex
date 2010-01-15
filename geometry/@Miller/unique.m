function m = unique(m,varargin)
% disjoint list of Miller indice
%
%% Syntax
%  m = symeq(m,<options>) - 
%
%% Input
%  m - @Miller
%
%% Output
%  m - @Miller

m = cunion(m,@(a,b) eq(a,b,varargin{:}));
