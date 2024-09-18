function intersected_cells = intersected(grains,varargin)
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
%   plane = createPlane(P0,N)       % note different sequence of inputs!
%   is_intersected = grains.intersected(plane)   % plane in matGeom format
%
% Input
%  grains   - @grain3d
%  plane    - plane in matGeom format
% Output
%  grains  - @grain3d
%
% See also
% grain3d/slice

%% Processing inputs
% plane           - plane in matGeom Format
if nargin < 2
  error 'too few arguments'
elseif nargin == 2            
  if isa(varargin{1},'vector3d')                  % set of points
    plane = fitPlane(varargin{1}.xyz);
  else
    plane = varargin{1};                          % plane in matGeom format
  end
elseif nargin == 3
  if isa(varargin{1},'vector3d')                  % N & P0 as vector3d
    varargin{1} = varargin{1}.xyz;
    varargin{2} = varargin{2}.xyz;
  end                                             % N & P0 as xyz
  plane = createPlane(varargin{2},varargin{1});   % different sequence of inputs for createPlane: P0,N
elseif nargin >= 4
  pts = [varargin{1:3}];                          % three points within the plane
  plane = fitPlane(pts.xyz);
else
  error 'Input error'
end

assert(isPlane(plane),'Input error')
%%
V = grains.boundary.allV.xyz;   % all vertices as xyz
F = grains.F;                   % all faces (polys) as nx1-cell or nx3 array
I_GF = grains.I_GF;

% look which of the vertices are above and which below
V_above_below = isBelowPlane(V,plane);
% look which boundary faces have vertices above AND below
if iscell(F)
  F_affected = cellfun(@(a) any(V_above_below(a))&~all(V_above_below(a)),F);
else
  F_affected = V_above_below(F);
  F_affected = any(F_affected,2)&~all(F_affected,2);
end

F_affected = repmat(F_affected,[1 size(I_GF,1)])';
intersected_cells = any(logical(I_GF)&F_affected,2);
