function varargout = plot(grains,varargin)
% colorize grains, or more percise their faces
%
% Only outer faces, the inner grains have the color gray [0.5 0.5 0.5].
%
% Syntax
%   plot(grains)          % colorize by phase
%   plot(grains,property) % colorize by property
%   
% Example
%
%   plot(grains,grains.meanOrientation)
%   plot(grains,grains.volume)
%
% Input
%  grains  - @grain2d
%  property- n x 1 numeric or orientation
%
% See also
% grain2d/plot grain3Boundary/plot


gB = grains.boundary;
V = gB.allV;
poly = gB.poly;

if nargin>1 && isa(varargin{1},'orientation')
  % color by orientation

  oM = ipfColorKey(varargin{1});
  grainColor = oM.orientation2color(varargin{1});
  varargin{1} = [];

  faceColor = 0.5 .* ones(size(poly,1),3);
  isouter = ~all(gB.grainId,2);
  faceColor(isouter,:) = grainColor(nonzeros(gB.grainId(isouter,:)),:);

elseif nargin>1 && isnumeric(varargin{1})
  % color by property

  grainColor = varargin{1};
  varargin{1} = [];
  assert(numel(grainColor) == length(grains),...
    'Number of grains must be the same as the number of data');

  faceColor = NaN(size(poly,1),1);
  isouter = ~all(gB.grainId,2);
  faceColor(isouter,:) = grainColor(nonzeros(gB.grainId(isouter,:)),:);
  colorbar

elseif check_option(varargin,'FaceColor')
  faceColor = get_option(varargin, 'FaceColor') .* ones(size(poly,1),3);
else
  % color by phase

  grainColor = [1,1,1 ; grains.color];
  faceColor = 0.5 .* ones(size(poly,1),3);
  isouter = ~all(gB.phaseId,2);
  faceColor(isouter,:) = grainColor(nonzeros(gB.phaseId(isouter,:)),:);

end

  h = zeros(size(poly));
  for iPoly= 1:numel(poly)
  nodes = V(poly{iPoly}).xyz;
  h(iPoly) = patch(nodes(:, 1), nodes(:, 2), nodes(:, 3), faceColor(iPoly,:));
  end

  if nargout>0
    varargout = {h};
  end
end