function h = plot(grains,varargin)
% plot 3-dimensional grains, or more precise their faces
%
% Only outer faces, the inner grains have the color gray [0.5 0.5 0.5].
%
% Syntax
%   plot(grains)                              % colorize by phase
%   plot(grains,property)                     % colorize by property
%   plot(grains,'ipfz')                       % colorize by mean orientation
%   plot(grains,property,'LineStyle','none')  % adapt LineStyle
%
% Input
%  grains   - @grain3d
%  property - n × 1 numeric or orientation
%
% See also
% grain2d/plot grain3Boundary/plot


% create a new plot
%mtexFig = newMtexFigure('datacursormode',{@tooltip,grains},varargin{:});
mtexFig = newMtexFigure(varargin{:});
[mP,isNew] = newMapPlot('scanUnit','um','parent',mtexFig.gca,...
  'micronbar','off',varargin{:}, grains.how2plot);

if isempty(grains)
  if nargout==1, h = [];end
  return;
end

gB = grains.boundary;
V = gB.allV;
F = gB.F;

% Wind every outer face so that its normal points out of its grain, the
% sign grains.I_GF records. Lighting (camlight, lighting gouraud) shades by
% these normals; with half of them pointing inwards a lit grain shows dark
% stars wherever the two kinds of triangle meet. Inner faces, shared by two
% plotted grains, sum to zero and stay as they are.
inward = full(sum(grains.I_GF,1)).' < 0;
if iscell(F)
  F(inward) = cellfun(@fliplr,F(inward),'UniformOutput',false);
else
  F(inward,:) = fliplr(F(inward,:));
end

% transform orientations to color
ipfOpt = {'ipfDirection','inversePoleFigureDirection','ipfd'};
ipfDir = get_option(varargin,ipfOpt,zvector);
flag = get_flag(varargin,{'ipfx','ipfy','ipfz'},'');
if ~isempty(flag)
  dirs = [xvector,yvector,zvector];
  ipfDir = dirs(lower(flag(end)) == 'xyz');
end

grainColor = [];
if nargin>1 && isa(varargin{1},'orientation')

  oM = ipfColorKey(varargin{1});
  oM.ipfDirection = ipfDir;
  grainColor = oM.orientation2color(varargin{1});
  varargin(1) = [];

  if ~getMTEXpref('generatingHelpMode') && isempty(flag) && ~check_option(varargin,ipfOpt)
    disp('  I''m going to colorize the orientation data with the ');
    disp('  standard MTEX colorkey. To view the colorkey do:');
    disp(' ');
    disp('  colorKey = ipfColorKey(ori_variable_name)')
    disp('  plot(colorKey)')
  end

elseif ~isempty(flag) || check_option(varargin,ipfOpt)

  % the mean orientations of the grains, each phase by its own key
  grainColor = NaN(length(grains),3);
  for k = reshape(unique(grains.phaseId(grains.isIndexed)),1,[])
    ind = grains.phaseId == k;
    ori = orientation(grains.prop.meanRotation(ind),grains.CSList(k),...
      specimenSymmetryFor(grains.frame));
    oM = ipfColorKey(ori);
    oM.ipfDirection = ipfDir;
    grainColor(ind,:) = oM.orientation2color(ori);
  end

end

if ~isempty(grainColor)
  % color by orientation

  faceColor = 0.5 .* ones(size(F,1),3);

  % determine which is the outer face
  isouter = full(sum(grains.I_GF ,1)).' ~=0;
  [grainId,~] = find(grains.I_GF(:,isouter));

  % use the corresponding color
  faceColor(isouter,:) = grainColor(grainId,:);

elseif nargin>1 && isnumeric(varargin{1})
  % color by property

  grainColor = varargin{1};
  varargin(1) = [];

  assert(any(numel(grainColor) == length(grains) * [1,3]),...
    'Number of grains must be the same as the number of data');

  faceColor = NaN(size(F,1),size(grainColor,2));

  % determine which is the outer face
  isouter = full(sum(grains.I_GF ,1)).' ~=0;
  [grainId,~] = find(grains.I_GF(:,isouter));

  % use the corresponding color
  faceColor(isouter,:) = grainColor(grainId,:);

elseif check_option(varargin,'FaceColor')

  faceColor = str2rgb(get_option(varargin, 'FaceColor'));
  varargin = delete_option(varargin, 'FaceColor',1);

else
  % color by phase

  grainColor = grains.colorList;
  faceColor = 0.5 .* ones(size(F,1),3);

  % determine which is the outer face
  isouter = full(sum(grains.I_GF ,1)).' ~=0;
  [grainId,~] = find(grains.I_GF(:,isouter));

  % use the corresponding color
  faceColor(isouter,:) = grainColor(grains.phaseId(grainId),:);

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

% apply the plotting convention to the axis
mP.how2plot.setView(mP.ax);

pause(0.1)

fcw

if nargout==0, clear h; end

end