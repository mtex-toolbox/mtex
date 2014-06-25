function s = sum(v,d)
% sum of vectors
%
% Input
%  v - @vector3d 
%  dimensions - [double]
%
% Output
%  @vector3d

% find first non singular dimension
if nargin == 1, d = find(size(v.x)~=1, 1 ); end

% apply sum to each coordinate
s = v; 
s.opt = struct; % clear options (espcially required for resolution)
s.x = sum(v.x,d);
s.y = sum(v.y,d);
s.z = sum(v.z,d);
