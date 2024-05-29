function grains = intersected(grains,varargin)
% grain3d.intersected is a method to restrict 3D grain data to the cells
% that are intersected by a plane in 3D space 
%
% Syntax
%
%   N = vector3d(1,1,1)             % plane normal
%   P0 = vector3d(0.5, 0.5, 0.5)    % point within plane
%   grain = grains.intersected(N,P0)
%
%   V = vector3d([0 1 0],[0 1 1],[0 1 0])
%   grain = grains.intersected(V)       % set of points
%
%   plane = createPlane(P0,N)       % note different sequence of inputs!
%   grain = grains.intersected(plane)   % plane in matGeom format
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
log_I_GF = logical(grains.I_GF);

% look which of the vertices are above and which below
V_above_below = isBelowPlane(V,plane);

% cell array with all vertices for each grain
grains_V = cell(grains.size);
if iscell(F)
  for i = 1:size(log_I_GF,1)
    grains_V(i) = {unique([F{log_I_GF(i,:),:}])};
  end
else
  for i = 1:size(log_I_GF,1)
    grains_V(i) = {unique([F(log_I_GF(i,:),:)])};
  end
end

% search for grains, that have vertices above AND below the plane
intersected_cells = cellfun(@(cell) any(V_above_below(cell))&~all(V_above_below(cell)), grains_V);

grains = grains.subSet(intersected_cells);