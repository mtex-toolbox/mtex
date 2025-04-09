function varargout = plot(plane,varargin)
% plot planes in 3d space clipped by current axis
%
% Syntax
%   plot(plane)
%
% Input
%  plane - @plane3d
%
% See also
% patch

% extract color
if nargin>1 && isnumeric(varargin{1})
  % color by property

  color = varargin{1};
  varargin(1) = [];

  assert(any(numel(color) == numel(plane) * [1,3]),...
    'Number of grains must be the same as the number of data');

  if (numel(color) == numel(plane));  colorbar; end
  varargin = set_option(varargin,'FaceColor',color);

end

% where to plot
ax = get_option(varargin,'parent',gca);

% extract axis bounds to crop plane
ext = [ax.XLim ax.YLim ax.ZLim];

corners = vector3d(ext([1 3 5; 2 3 5; 2 4 5; 1 4 5; ...
  1 3 6; 2 3 6; 2 4 6; 1 4 6]));

edges = [1 2; 2 3; 3 4; 4 1;   % lower edges
         5 6; 6 7; 7 8; 8 5;   % upper edges
         1 5; 2 6; 3 7; 4 8];  % vertical edges

% the vertices and faces of the resulting polygons
V = vector3d;
F = nan(length(plane),6);

for i = 1:numel(plane)

  % intersection points plane / edges
  pts = plane(i).intersect(corners(edges));
  pts = unique(pts(~isnan(pts)));

  % compute angle with respect to some reference direction
  centroid = mean(pts);
  ref = orth(plane.N(i));
  omega = angle(pts-centroid,ref,plane.N(i));

  [~, order] = sort(omega); 
  F(i,1:length(omega)) = order;
  V = [V;pts]; %#ok<AGROW>

end

h = patch('Faces',F, 'Vertices',V.xyz, 'FaceAlpha',0.5, varargin{:});

if nargout>0, varargout = {h,ax}; end
