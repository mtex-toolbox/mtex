function [h,mP] = plot(grains,varargin)
% colorize grains
%
% Syntax
%   plot(grains)          % colorize by phase
%   plot(grains,property) % colorize by property
%   plot(grains,cS)       % visualize crystal shape 
%   plot(grains,S2F)      % visualize a tensorial property on top of the grains
%
% Input
%  grains  - @grain2d
%  cS      - @crystalShape
%
%  PatchProperty - see documentation of patch objects for manipulating the apperance, e.g. 'EdgeColor'
%                
% Options
%  noBoundary  - do not plot boundaries 
%  displayName - name used in legend
%  region      - [xmin, xmax, ymin, ymax] of the plotting region 
%  scale       - scaling of crystal shapes and tensorial properties (0.3)
%
% See also
% EBSD/plot grainBoundary/plot

% --------------------- compute colorcoding ------------------------

% create a new plot
%mtexFig = newMtexFigure('datacursormode',{@tooltip,grains},varargin{:});
mtexFig = newMtexFigure(varargin{:});
[mP,isNew] = newMapPlot('scanUnit',grains.scanUnit,'parent',mtexFig.gca,...
  varargin{:},grains.plottingConvention);

if isempty(grains)
  if nargout==1, h = [];end
  return;
end

% transform orientations to color
if nargin>1 && isa(varargin{1},'orientation')
  
  oM = ipfColorKey(varargin{1});
  varargin{1} = oM.orientation2color(varargin{1});
  
  if ~getMTEXpref('generatingHelpMode')
    disp('  I''m going to colorize the orientation data with the ');
    disp('  standard MTEX colorkey. To view the colorkey do:');
    disp(' ');
    disp('  colorKey = ipfColorKey(ori_variable_name)')
    disp('  plot(colorKey)')
  end
end

plotBoundary = true;
% allow to plot grain faces only without boundaries
if check_option(varargin,'noBoundary'),plotBoundary = false; end

% turn logical into double
if nargin>1 && islogical(varargin{1}), varargin{1} = double(varargin{1}); end

% numerical data are given
if nargin>1 && isnumeric(varargin{1})
  
  property = varargin{1};
  
  assert(any(numel(property) == length(grains) * [1,3]),...
    'Number of grains must be the same as the number of data');

  legendNames = get_option(varargin,'displayName');
  
    % if many legend names are given - seperate grains by color / value
  if iscell(legendNames) && max(property)<50
  
    varargin = delete_option(varargin,'displayName',1);
    
    % plot polygons
    for k = 1:max(property)
      h{k} = plotFaces(grains.poly(property==k), grains.V, ind2color(k),...
        'parent', mP.ax,varargin{:},'DisplayName',legendNames{k}); %#ok<AGROW>
      
      % reactivate legend information
      set(get(get(h{k}(end),'Annotation'),'LegendInformation'),'IconDisplayStyle','on');
      hold on
    end
    hold off
  
  else % % plot polygons

    h = plotFaces(grains.poly,grains.V,property,'parent', mP.ax,varargin{:});
  
  end

elseif nargin>1 && isa(varargin{1},'vector3d')
  
  scaling = sqrt(grains.area);
    
  p = axialSymbol(grains.centroid,varargin{1},scaling,varargin{:});
  
  p.Parent = mP.ax;
    
  plotBoundary = false;
 
elseif nargin>1 && isa(varargin{1},'crystalShape')
  
  scaling = sqrt(grains.area);
  cS = scaling .* rotate(varargin{1},grains.meanOrientation); 
  pos = grains.centroid + 1.1 * max(abs(dot(cS.V,grains.N))).' * grains.N;
    h = plot(pos + cS,'parent', mP.ax,varargin{:});
  
  plotBoundary = false;
  
elseif nargin>1 && (isa(varargin{1},'S2Fun') || isa(varargin{1},'ipfColorKey'))
  
  % extract spherical function
  S2F = varargin{1};
  if isa(S2F,'ipfColorKey'), S2F = S2Fun(S2F); end
  if length(S2F)==3, varargin = ['rgb',varargin]; end
  
  % position in the map
  scaling = sqrt(grains.area);
  shift = grains.centroid + 2*scaling *grains.N;
  
  for k = 1:length(grains)

    h(k) = plot(rotate(S2F,grains.meanOrientation(k)),'parent', mP.ax,...
    'shift',shift.subSet(k),varargin{:},'scale',0.3*scaling(k),'3d'); %#ok<AGROW>
    
  end
  
  plotBoundary = false;
  
elseif check_option(varargin,'FaceColor')
  
  % plot polygons
  color = str2rgb(get_option(varargin,'FaceColor'));
  h = plotFaces(grains.poly,grains.V,color,'parent', mP.ax,varargin{:});
  
  % reactivate legend information
  if check_option(varargin,'displayName')
    set(get(get(h(end),'Annotation'),'LegendInformation'),'IconDisplayStyle','on');
  end
  
else % otherwise phase plot

  for k=1:numel(grains.phaseMap)
      
    ind = grains.phaseId == k;
    
    if ~any(ind), continue; end
    
    if check_option(varargin,'grayScale')
      color = 1 - (k-1)/(numel(grains.phaseMap)) * [1,1,1];
    else
      color = grains.subSet(ind).color;
    end
    
    if ischar(color), [~,color] = colornames(getMTEXpref('colorPalette'),color); end

    % plot polygons
    h{k} = plotFaces(grains.poly(ind),grains.V,color,...
      'parent', mP.ax,'DisplayName',grains.mineralList{k},varargin{:}); %#ok<AGROW>

    % reactivate legend information
    if ~isempty(h{k})
      set(get(get(h{k}(end),'Annotation'),'LegendInformation'),'IconDisplayStyle','on');
    end
        
  end

  % dummy set DisplayName to display legend
  varargin = [varargin,{'DisplayName',''}];
  
end

% we have to plot grain boundary individually
if plotBoundary
  hold on
  hh = plot(grains.boundary,varargin{:});
  set(get(get(hh(1),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
  hold off
end
  
if check_option(varargin,'DisplayName') 
  legend('-DynamicLegend','location','NorthEast');
end

% keep track of the extent of the graphics
% this is needed for the zoom: TODO maybe this can be done better
if isNew
  
  region = get_option(varargin,'region');
  if ~isempty(region)
    set(mP.ax,'XLim',region(1:2),'YLim',region(3:4))
  else
    axis(mP.ax,'tight'); 
  end
  
  mtexFig.drawNow('figSize',getMTEXpref('figSize'),varargin{:});
end

% allow change of aspect ratio only for single figures
if ~isstruct(mtexFig)
  mtexFig.keepAspectRatio = isscalar(mtexFig.children); 
end

% datacursormode does not work with grains due to a Matlab bug
datacursormode off

% define a hand written selector
set(gcf,'WindowButtonDownFcn',{@spatialSelection});
try
  setappdata(mP.ax,'grains',[grains;getappdata(mP.ax,'grains')]);
catch
  warning('still can not concatenate grains on different slices')
end

if nargout == 0, clear h;end

end


function spatialSelection(src,~)

pos = get(gca,'CurrentPoint');
%key = get(src, 'CurrentCharacter');
%src.SelectionType
grains = getappdata(gca,'grains');

idSelected = getappdata(gca,'idSelected');
handleSelected = getappdata(gca,'handleSelected');
if isempty(idSelected) || length(idSelected) ~= length(grains)
  idSelected = false(size(grains));
  handleSelected = cell(size(grains));
end


localId = findByLocation(grains,pos(1,:));

grain = grains.subSet(localId);

if isempty(grain), return; end

% remove old selection
if strcmpi(src.SelectionType,'normal')
  idSelected = false(size(grains));
  try delete([handleSelected{:}]); end %#ok<TRYNC>
elseif strcmpi(src.SelectionType,'extend')
  try delete([handleSelected{localId}]); end %#ok<TRYNC>
  handleSelected{localId} = [];
end

% remember new selection
idSelected(localId) = ~idSelected(localId);
if idSelected(localId)
  hold on
  handleSelected{localId} = plot(grain.boundary,'lineColor','w','linewidth',4);
  hold off
end

txt{1} = ['grainId = '  num2str(unique(grain.id))];
if grain.isIndexed
  txt{2} = ['phase = ', grain.mineral];
else
  txt{2} = 'phase = not indexed';
end
if size(grains.V,2) == 3
  txt{3} = ['(x,y,z) = ', xnum2str(pos(1,:),'delimiter',', ')];
else
  txt{3} = ['(x,y) = ', xnum2str(pos(1,:),'delimiter',', ')];
end
if grain.isIndexed
  txt{4} = ['Euler = ' char(grain.meanOrientation,'nodegree')];
end
%if ~isempty(value), txt{end+1} = ['Value = ' xnum2str(value(1))]; end

for k = 1:length(txt)
  disp(txt{k});
end
disp(' ');

setappdata(gca,'idSelected',idSelected);
setappdata(gca,'handleSelected',handleSelected);

end


% ------------------ Tooltip function -----------------------------
function txt = tooltip(empt,eventdata,grains) %#ok<INUSL>

[pos,~,value] = getDataCursorPos(gcm);
try
  grain = grains.subSet(findByLocation(grains,[pos(1) pos(2)]));
catch
  grain = [];
end

if numel(grain)>0

  grain = grain.subSet(1);
  txt{1} = ['grainId = '  num2str(unique(grain.id))];
  txt{2} = ['phase = ', grain.mineral];
  txt{3} = ['(x,y) = ', xnum2str(pos(1:2),'delimiter',', ')];
  if grain.isIndexed
    txt{4} = ['Euler = ' char(grain.meanOrientation,'nodegree')];
  end
  if ~isempty(value)
    txt{end+1} = ['Value = ' xnum2str(value(1))];
  end
else
  txt = 'no data';
end

end

% ----------------------------------------------------------------------
function h = plotFaces(poly,V,d,varargin)

if numel(poly) > 3 && size(d,1) == 1 && size(d,2) == numel(poly)
  d = d.';
end

if size(d,1) == 1, d = repmat(d,numel(poly),1); end

if check_option(varargin,'region')
  region = get_option(varargin,'region');
  ind = cellfun(@(p) any(V(p,1)>=region(1) & V(p,1)<=region(2) & ...
    V(p,2)>=region(3) & V(p,2)<=region(4)),poly);
  
  d = d(ind,:);
  poly = poly(ind);
  
  % cut polygons - TODO!!
  %ind = cellfun(@(p) ~all(V(p,1)>=region(1) & V(p,1)<=region(2) & ...
  %  V(p,2)>=region(3) & V(p,2)<=region(4)),poly);
  %reg = polyshape(region([1 2 2 1]),region([3 3 4 4]));
  %for k = find(ind).'
  %  p = polyshape(V(poly{k},:));
  %  [p2,sId,vId] = intersect(p,reg);
  %end

end

numParts = fix(log(max(cellfun('prodofsize',poly)))/2);
Parts = splitdata(cellfun('prodofsize',poly),numParts,'ascend');

obj.FaceColor = 'flat';
obj.EdgeColor = 'None';
obj.hitTest = 'off';
h = [];

for p=numel(Parts):-1:1
  zOrder = Parts{p}(end:-1:1); % reverse

  obj.FaceVertexCData = d(zOrder,:);

  Faces = poly(zOrder);
  s     = cellfun('prodofsize',Faces).';
  cs    = [0 cumsum(s)];

  % reduce face-vertex indices to required
  Faces = [Faces{:}];
  vert  = sparse(Faces,1,1,length(V),1);
  obj.Vertices = V(vert>0).xyz;

  vert  = cumsum(full(vert)>0);
  Faces = nonzeros(vert(Faces));

  % fill the faces-edge list for patch
  obj.Faces = NaN(numel(s),max(s));
  for k=1:numel(s)
    obj.Faces(k,1:s(k)) = Faces( cs(k)+1:cs(k+1) );
  end

  if check_option(varargin,{'transparent','translucent','FaceAlpha'})
    s = get_option(varargin,{'transparent','translucent','FaceAlpha'},1,'double');
    dg = obj.FaceVertexCData;
    if size(d,2) == 3 % rgb
      obj.FaceVertexAlphaData = s.*(1-min(dg,[],2));
    else
      obj.FaceVertexAlphaData = s.*dg./max(dg);
    end
    obj.AlphaDataMapping = 'none';
    obj.FaceAlpha = 'flat';
  end

  % plot the patches
  h(p) = optiondraw(patch(obj),varargin{:});

  % remove them from legend
  set(get(get(h(p),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
  
end

end

