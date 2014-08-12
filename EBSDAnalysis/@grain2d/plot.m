function h = plot(grains,varargin)
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
mP = newMapPlot(varargin{:});

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
  
else % otherwise phase plot

  for k=1:numel(grains.phaseMap)
      
    ind = grains.phaseId == k;
    
    if ~any(ind), continue; end
    
    color = grains.subSet(ind).color;

    % plot polygons
    h{k} = plotFaces(grains.poly(ind),grains.V,color,...
      'parent', mP.ax,varargin{:}); %#ok<AGROW>

    % reactivate legend information
    set(h{k},'DisplayName',grains.mineralList{k});
    set(get(get(h{k}(end),'Annotation'),'LegendInformation'),'IconDisplayStyle','on');

  end
  
  legend('-DynamicLegend','location','NorthEast');
    
end

% keep track of the extend of the graphics
% this is needed for the zoom: TODO maybe this can be done better
axis(mP.ax,'tight');

if nargout == 0, clear h;end


% set data cursor
%dcm_obj = datacursormode(gcf);
%set(dcm_obj,'SnapToDataVertex','off')
%set(dcm_obj,'UpdateFcn',{@tooltip,grains});

%datacursormode on;


% -----------------------------------------------------------------
% ------------ private functions ----------------------------------
% -----------------------------------------------------------------

% Tooltip function
function txt = tooltip(empt,eventdata,grains) %#ok<INUSL>


[pos,value] = getDataCursorPos(gcf);
try
  sub = findByLocation(grains,[pos(1) pos(2)]);
catch
  sub = [];
end

if numel(sub)>0

  txt{1} = ['Grain: '  num2str(unique(sub.id))];
  txt{2} = ['Phase: ', sub.mineral];
  if ~isNotIndexed(sub)
    txt{3} = ['Orientation: ' char(sub.meanOrientation,'nodegree')];
  end
  if ~isempty(value)
    txt{3} = ['Value: ' xnum2str(value)];
  end
else
  txt = 'no data';
end


% ----------------------------------------------------------------------
function h = plotFaces(boundaryEdgeOrder,V,d,varargin)

% add holes as polygons
hole = cellfun('isclass',boundaryEdgeOrder,'cell');

% split into holes an bounding
holeEdgeOrder = ...
  cellfun(@(x) x(2:end),boundaryEdgeOrder(hole),'UniformOutput',false);
boundaryEdgeOrder(hole) = ...
  cellfun(@(x) x{1},boundaryEdgeOrder(hole),'UniformOutput',false);

Polygons = [boundaryEdgeOrder(:)' holeEdgeOrder{:}];


if size(d,1) ~= numel(boundaryEdgeOrder) && ...
  size(d,2) == numel(boundaryEdgeOrder), d = d.'; end

% how to colorize holes 
% d(numel(boundaryEdgeOrder)+1:numel(Polygons),: ) = 1;
if size(d,1) == 1
  d = repmat(d,numel(boundaryEdgeOrder),1);
end
d(numel(boundaryEdgeOrder)+1:numel(Polygons),: ) = NaN;

A = cellArea(V,Polygons);

numParts = fix(log(max(cellfun('prodofsize',Polygons)))/2);
Parts = splitdata(A,numParts,'ascend');

obj.FaceColor = 'flat';

for p=numel(Parts):-1:1
  zOrder = Parts{p}(end:-1:1); % reverse

  obj.FaceVertexCData = d(zOrder,:);

  Faces = Polygons(zOrder);
  s     = cellfun('prodofsize',Faces);
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

function A = cellArea(V,D)

D = D(:);
A = zeros(size(D));

faceOrder = [D{:}];

x = V(faceOrder,1);
y = V(faceOrder,2);

dF = full(x(1:end-1).*y(2:end)-x(2:end).*y(1:end-1));

cs = [0; cumsum(cellfun('prodofsize',D))];
for k=1:numel(D)
  ndx = cs(k)+1:cs(k+1)-1;
  A(k) = abs(sum(dF(ndx))*0.5);
end
