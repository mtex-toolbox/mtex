function ebsd = slice(ebsd3,plane,varargin)
% slice 3d-ebsd to obtain 2d-ebsd
%
% Syntax
%   N    = vector3d(1,1,1)             % plane normal
%   P0   = vector3d(0.5, 0.5, 0.5)    % point within plane
%   ebsd = ebsd3.slice(N,P0)
%
%   plane = plane3d.fit(v)
%   ebsd  = ebsd3.slice(plane)  
%
% Input
%  ebsd3 - @EBSD3
%  plane - @plane3d
%
% Output
%  ebsd  - @EBSD
%
% See also
% EBSD grain3d/slice

if ~isa(plane,'plane3d'), plane = plane3d(plane,varargin{:}); end

ext = ebsd3.extent;

corners = vector3d(ext([1 3 5; 2 3 5; 2 4 5; 1 4 5; ...
  1 3 6; 2 3 6; 2 4 6; 1 4 6])).';

% reference point in the plane
pos0 = plane.project(corners(1));

% select an orthonormal basin in the plane
ext = vector3d(-diag(diff(reshape(ebsd3.extent,2,3)).'));
d2 = plane.project(ext);
[~,ind] =  max(norm(d2));
u = normalize(d2(ind));
v = cross(plane.N,u);

% compute u,v coordinates of the corners
coords = dot(corners - pos0,[u,v])./ ebsd3.dPos;

% minimal and maximal coordinates 
ijmin = floor(min(coords)) - 1;
ijmax =  ceil(max(coords)) + 1; 

newPos = pos0 + ebsd3.dPos .* ...
  ((ijmin(1):ijmax(1)) .* u + (ijmin(2):ijmax(2)).' .* v);

ebsd = interp(ebsd3,newPos);
ebsd.N = plane.N;

end