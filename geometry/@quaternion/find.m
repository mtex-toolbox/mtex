function [ind,d] = find(quats,quat,epsilon,varargin)
% return indece and distance of all nodes within a eps neighborhood
%
%% Syntax  
% [ind,dist] = find(rotations,rotation,radius)
%
%% Input
%  quats - @quaternion
%  quat  - @quaternion
%  radius - double
%% Output
%  [indece, distances]
%

d = dot_outer(quats,quat);
  
if nargin == 2
  [d,ind] = max(d,[],1);
else
  ind = d > cos(epsilon/2);
end

