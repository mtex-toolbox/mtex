function [ind,d] = find(v,w,epsilon,varargin)
% return index of all points in a epsilon neighborhood of a vector
%
%% Syntax  
% ind = find(v,w,epsilon) - find all points out of v in a epsilon neighborhood of w
% ind = find(v,w)         - find closest point out of v to w
%
%% Input
%  v, w    - @vector3d
%  epsilon - double
%
%% Options
%  antipodal      - include [[AxialDirectional.html,antipodal symmetry]]
%
%% Output
%  ind     - int32        

% compute distances
d = dot_outer(v,w,varargin{:});

% find neigbours
if nargin >= 3
  ind = d > cos(epsilon);
else
  [d,ind] = max(d,[],1);
end
