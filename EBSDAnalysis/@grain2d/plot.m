function [h,mP] = plot(grains,varargin)
% colorize grains
%
% Syntax
%   plot(grains)          % colorize by phase
%   plot(grains,property) % colorize by property
%
% Input
%  grains  - @grain2d
%
%  PatchProperty - see documentation of patch objects for manipulating the
%                 apperance, e.g. 'EdgeColor'
% See also
% EBSD/plot grainBoundary/plot

% --------------------- compute colorcoding ------------------------

% create a new plot
[mtexFig,isNew] = newMtexFigure('datacursormode',{@tooltip,grains},varargin{:});
mP = newMapPlot('scanUnit',grains.scanUnit,'parent',mtexFig.gca,varargin{:});

if isempty(grains)
  if nargout==1, h = [];end
  return;
end

% transform orientations to color
if nargin>1 && isa(varargin{1},'orientation')
  
  oM = ipdfHSVOrientationMapping(varargin{1});
  varargin{1} = oM.orientation2color(varargin{1});
  disp('  I''m going to colorize the orientation data with the ');
  disp('  standard MTEX colorkey. To view the colorkey do:');
  disp(' ');
  disp('  oM = ipdfHSVOrientationMapping(ori_variable_name)')
  disp('  plot(oM)')
end

% numerical data are given
if nargin>1 && isnumeric(varargin{1})
  
  property = varargin{1};
  
  assert(any(numel(property) == length(grains) * [1,3]),...
  'Number of grains must be the same as the number of data');
  
  % plot polygons
  h = plotFaces(grains.poly,grains.V,property,'parent', mP.ax,varargin{:});
  
elseif check_option(varargin,'FaceColor')
  
  % plot polygons
  color = get_option(varargin,'FaceColor');
  h = plotFaces(grains.poly,grains.V,color,'parent', mP.ax,varargin{:});
  
  % reactivate legend information
  set(get(get(h(end),'Annotation'),'LegendInformation'),'IconDisplayStyle','on');
  
else % otherwise phase plot

  for k=1:numel(grains.phaseMap)
      
    ind = grains.phaseId == k;
    
    if ~any(ind), continue; end
    
    color = grains.subSet(ind).color;

    % plot polygons
    h{k} = plotFaces(grains.poly(ind),grains.V,color,...
      'parent', mP.ax,'DisplayName',grains.mineralList{k},varargin{:}); %#ok<AGROW>

    % reactivate legend information
    set(get(get(h{k}(end),'Annotation'),'LegendInformation'),'IconDisplayStyle','on');

  end

end

% we have to plot grain boundary individually
hold on
hh = plot(grains.boundary,varargin{:});
set(get(get(hh,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
hold off

warning('off','MATLAB:legend:PlotEmpty');
legend('-DynamicLegend','location','NorthEast');
warning('on','MATLAB:legend:PlotEmpty');

% keep track of the extend of the graphics
% this is needed for the zoom: TODO maybe this can be done better
axis(mP.ax,'tight'); set(mP.ax,'zlim',[0,1]);

if nargout == 0, clear h;end

if isNew, mtexFig.drawNow('figSize',getMTEXpref('figSize'),varargin{:}); end
mtexFig.keepAspectRatio = false;

end

% ------------------ Tooltip function -----------------------------
function txt = tooltip(empt,eventdata,grains) %#ok<INUSL>

[pos,value] = getDataCursorPos(gcm);
try
  grain = grains.subSet(findByLocation(grains,[pos(1) pos(2)]));
catch
  grain = [];
end

if numel(grain)>0

  grain = grain.subSet(1);
  txt{1} = ['grainId  '  num2str(unique(grain.id))];
  txt{2} = ['phase    ', grain.mineral];
  txt{3} = ['x,y       ', xnum2str(pos(1)) ', ' xnum2str(pos(2))];
  if grain.isIndexed
    txt{4} = ['Euler    ' char(grain.meanOrientation,'nodegree')];
  end
  if ~isempty(value)
    txt{end+1} = ['Value    ' xnum2str(value(1))];
  end
else
  txt = 'no data';
end

end

% ----------------------------------------------------------------------
function h = plotFaces(poly,V,d,varargin)

if size(d,1) ~= numel(poly) && ...
  size(d,2) == numel(poly), d = d.'; end

if size(d,1) == 1, d = repmat(d,numel(poly),1); end

numParts = fix(log(max(cellfun('prodofsize',poly)))/2);
Parts = splitdata(cellfun('prodofsize',poly),numParts,'ascend');

obj.FaceColor = 'flat';
obj.EdgeColor = 'None';

for p=numel(Parts):-1:1
  zOrder = Parts{p}(end:-1:1); % reverse

  obj.FaceVertexCData = d(zOrder,:);

  Faces = poly(zOrder);
  s     = cellfun('prodofsize',Faces).';
  cs    = [0 cumsum(s)];

  % reduce face-vertex indices to required
  Faces = [Faces{:}];
  vert  = sparse(Faces,1,1,size(V,1),1);
  obj.Vertices = V(vert>0,:);

  vert  = cumsum(full(vert)>0);
  Faces = nonzeros(vert(Faces));

  % fill the faces-edge list for patch
  obj.Faces = NaN(numel(s),max(s));
  for k=1:numel(s)
    obj.Faces(k,1:s(k)) = Faces( cs(k)+1:cs(k+1) );
  end

  if check_option(varargin,{'transparent','translucent'})
    s = get_option(varargin,{'transparent','translucent'},1,'double');
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

