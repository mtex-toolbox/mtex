function varargout = plot(grains,varargin)
% colorize 3 dimensional grains, or more precise their faces
%
% Only outer faces, the inner grains have the color gray [0.5 0.5 0.5].
%
% Syntax
%   plot(grains)                              % colorize by phase
%   plot(grains,property)                     % colorize by property
%   plot(grains,property,'LineStyle','none')  % adapt LineStyle
%
% Input
%  grains  - @grain3d
%  property- n x 1 numeric or orientation
%
%
% See also
% grain2d/plot grain3Boundary/plot


gB = grains.boundary;
V = gB.allV;
F = gB.F;

if nargin>1 && isa(varargin{1},'orientation')
  % color by orientation

  oM = ipfColorKey(varargin{1});
  grainColor = oM.orientation2color(varargin{1});
  varargin(1) = [];

  faceColor = 0.5 .* ones(size(F,1),3);

  isouter = sum(grains.I_GF ,1)';
  faceColor(isouter==1,:) = grainColor(id2ind(grains,gB.grainId(isouter==1,1)),:);
  faceColor(isouter==-1,:) = grainColor(id2ind(grains,gB.grainId(isouter==-1,2)),:);

elseif nargin>1 && isnumeric(varargin{1})
  % color by property

  grainColor = varargin{1};
  varargin(1) = [];

  assert(any(numel(grainColor) == length(grains) * [1,3]),...
    'Number of grains must be the same as the number of data');

  faceColor = NaN(size(F,1),size(grainColor,2));

  isouter = sum(grains.I_GF ,1)';
  faceColor(isouter==1,:) = grainColor(gB.grainId(isouter==1,1),:);
  faceColor(isouter==-1,:) = grainColor(gB.grainId(isouter==-1,2),:);

  if (numel(grainColor) == length(grains));  colorbar; end

elseif check_option(varargin,'FaceColor')
  faceColor = repmat(str2rgb(get_option(varargin, 'FaceColor')), size(F,1),1);
  varargin = delete_option(varargin, 'FaceColor',1);
else
  % color by phase

  grainColor = [1,1,1 ; grains.color];
  faceColor = 0.5 .* ones(size(F,1),3);

  isouter = sum(grains.I_GF ,1)';
  faceColor(isouter==1,:) = grainColor(gB.phaseId(isouter==1,1),:);
  faceColor(isouter==-1,:) = grainColor(gB.phaseId(isouter==-1,2),:);

end

% to prevent errors from empty varargin, but not to check every iteration
if isempty(varargin); varargin = set_option(varargin,'LineStyle','-'); end

if iscell(F)
  h = zeros(size(F,1),1);
  for iF = 1:numel(F)
  nodes = V(F{iF}).xyz;
  h(iF) = patch(nodes(:, 1), nodes(:, 2), nodes(:, 3), faceColor(iF,:), varargin{:});
  end

else  % speedup for triangulated meshes

  if size(faceColor,2) == 1     % color by value
    h = patch('Faces', F(:,:), 'Vertices', V.xyz, 'FaceVertexCData', faceColor, 'FaceColor','flat', varargin{:});
    colorbar
  else                        	% color by rgb triplet
    [C,~,ic] = unique(faceColor,'rows');
    h = zeros(size(C,1),1);
    for i = 1:size(C,1)
      ind = (ic == i);
      h(i) = patch('Faces', F(ind,:), 'Vertices', V.xyz, 'FaceColor', C(i,:), varargin{:});
    end
  end
end

  if nargout>0
    varargout = {h};
  end
end