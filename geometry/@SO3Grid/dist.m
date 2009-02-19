function d = dist(SO3G,q,varargin)
% return indece and distance of all nodes within a eps neighborhood
%
%% Syntax  
%  d = dist(SO3G,nodes,radius)
%
%% Input
%  SO3G   - @SO3Grid
%  nodes  - @quaternion
%  radius - double
%% Output
%  d      - sparse distance matrix

d = 2*acos(dot_outer(SO3G,q,varargin{:}));
