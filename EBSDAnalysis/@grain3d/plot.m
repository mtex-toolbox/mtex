function h = plot(grains,varargin)
% plot 3-dimensional grains, or more precise their faces
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


% create a new plot
%mtexFig = newMtexFigure('datacursormode',{@tooltip,grains},varargin{:});
mtexFig = newMtexFigure(varargin{:});
[mP,isNew] = newMapPlot('scanUnit','um','parent',mtexFig.gca,...
  grains.allV.plottingConvention, varargin{:});

if isempty(grains)
  if nargout==1, h = [];end
  return;
end

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
  
elseif check_option(varargin,'FaceColor')

  faceColor = str2rgb(get_option(varargin, 'FaceColor'));
  varargin = delete_option(varargin, 'FaceColor',1);

else
  % color by phase

  grainColor = [1,1,1 ; grains.color];
  faceColor = 0.5 .* ones(size(F,1),3);

  isouter = sum(grains.I_GF ,1)';
  faceColor(isouter==1,:) = grainColor(gB.phaseId(isouter==1,1),:);
  faceColor(isouter==-1,:) = grainColor(gB.phaseId(isouter==-1,2),:);

end

pObj.Vertices = V.xyz;
pObj.parent = mP.ax;

if size(faceColor,1) == size(F,1)
  pObj.FaceColor = 'flat';
  pObj.FaceVertexCData = faceColor;
else
  pObj.FaceColor = faceColor;
end

% extract faces
if iscell(F)
  pObj.Faces = nan(length(F),max(cellfun(@numel,F)));
  for iF = 1:numel(F)
    pObj.Faces(iF,1:length(F{iF})) = F{iF};
  end
else
  pObj.Faces = F;
end

% do plot
h = optiondraw(patch(pObj),varargin{:});

pause(0.1)

fcw

if nargout==0, clear h; end

end