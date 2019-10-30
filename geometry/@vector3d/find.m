function [ind,d] = find(v,w,epsilon,varargin)
% return index of all points in a epsilon neighborhood of a vector
%
% Syntax
%   ind = find(v,w,epsilon) % find all points out of v in a epsilon neighborhood of w
%   ind = find(v,w)         % find closest point out of v to w
%
% Input
%  v, w    - @vector3d
%  epsilon - double
%
% Options
%  antipodal - include <VectorsAxes.html antipodal symmetry>
%
% Output
%  ind     - int32

% compute distances
d = angle_outer(v,w,varargin{:});

% find neigbours
if nargin >= 3
  if epsilon == 1
    [d,ind] = min(d,[],1);
  else
    ind = d < epsilon;
  end
else
  [d,ind] = min(d,[],1);
end
