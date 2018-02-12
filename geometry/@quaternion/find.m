function [ind,d] = find(lookup,ref,epsilon,varargin)
% return indece and distance of all nodes within a eps neighborhood
%
% Syntax  
%   % find for each quaternion in ref the closest quaternion in lookup 
%   [ind,d] = find(table,ref,radius)
%
%   % find for each quaternion in ref all quaternion in lookup that have
%   % angle not larger then epsilon
%   [ind,d] = find(table,rotation,epsilon)
%
% Input
%  table - @quaternion
%  ref   - @quaternion
%  epsilon - double
%
% Output
%  ind - 
%  d - 
%

d = dot_outer(lookup,ref);
  
if nargin == 2
  [d,ind] = max(d,[],1);
else
  ind = d > cos(epsilon/2);
end
