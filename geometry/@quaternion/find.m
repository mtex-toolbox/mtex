function [ind,d] = find(lookup,ref,epsilon,varargin)
% return indece and distance of all nodes within a eps neighborhood
%
% Syntax  
%   % find for each quaternion in ref the closest quaternion in table
%   [ind,d] = find(table, ref)
%
%   % find for each quaternion in ref all quaternion in lookup that have
%   % angle not larger then epsilon
%   [ind,d] = find(table, rot_ref, epsilon)
%
%   % find all quaternion which have distant to fibre f less then epsilon
%   [ind,d] = find(table, f_ref, epsilon)
%
% Input
%  table   - @quaternion
%  rot_ref - reference @quaternion
%  f_ref   - reference @fibre 
%  epsilon - maximum distance
%
% Output
%  ind - index of the found @quaternions
%  d   - actual distances
%

if isa(ref,'fibre')
  
  ind = angle(ref,lookup) < epsilon;  
  
else
  
  d = dot_outer(lookup,ref);
  
  if nargin == 2
    [d,ind] = max(d,[],1);
  else
    ind = d > cos(epsilon/2);
  end
end
