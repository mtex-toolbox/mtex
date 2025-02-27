function out = intersected(grains,plane,varargin)
% grain3d.intersected is a method to determine if a 3D grain data cell
% is intersected by a plane in 3D space 
%
% Syntax
%
%   N = vector3d(1,1,1)             % plane normal
%   P0 = vector3d(0.5, 0.5, 0.5)    % point within plane
%   is_intersected = grains.intersected(N,P0)
%
%   V = vector3d([0 1 0],[0 1 1],[0 1 0])
%   is_intersected = grains.intersected(V)       % set of points
%   grains = grains(is_intersected)
%
% Input
%  grains - @grain3d
%  plane  - @plane3d
%
% Output
%  out  - logical
%
% See also
% grain3d/slice

if ~isa(plane,'plane3d'), plane = plane3d(plane,varargin{:}); end

% compute signed distance to all vertices
d = plane.dist(grains.allV);

[vId,gId] = find(grains.boundary.I_VG);

out = accumarray(gId,d(vId),[max(gId) 1],@max) > 0 & ...
  accumarray(gId,d(vId),[max(gId) 1],@min) < 0;

