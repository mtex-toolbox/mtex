function [ind,d] = find(ori,o,epsilon,varargin)
% return indece and distance of all nodes within a eps neighborhood
%
%% Syntax  
% [ind,dist] = find(orientations,nodes,radius)
%
%% Input
%  orientations   - @orientation
%  nodes  - @orientation / @quaternion
%  radius - double
%% Output
%  [indece, distances]
%

d = dot_outer(ori,o);
  
if nargin == 2
  [d,ind] = max(d,[],1);
else
  ind = d<epsilon;
end

