function h = plot(grains,varargin)
% colorize grains
%
% Syntax
%   plot(grains) % colorize by phase
%   
%   plot(grains,property) % colorize by property
%
% Input
%  grains  - @Grain2d
%
% Options
%  property - colorize a grains by given property, variants are:
%
%    * |'phase'| -- make a phase map.
%
%    * |'orientation'| -- colorize a grain after its orientaiton
%
%            plot(grains,'property','orientation',...
%              'colorcoding','ipdf');
%
%    * numeric array with length of number of grains.
%
%  PatchProperty - see documentation of patch objects for manipulating the
%                 apperance, e.g. 'EdgeColor'
% See also
% Grain3d/plotGrains

% --------------------- compute colorcoding ------------------------

% create a new plot
mP = newMapPlot(varargin{:});

% what to plot - phase is default
if nargin>1 && isnumeric(varargin{1})
  property = varargin{1};
elseif numel(grains.indexedPhasesId)==1
  
  grains = grains.subSet(grains.phaseId == grains.indexedPhasesId);
  
  oM = ipdfHSVOrientationMapping(grains);
  property = oM.orientation2color(grains.meanOrientation);
  disp('  I''m going to colorize the ebsd data with the ');
  disp('  standard MTEX colorkey. To view the colorkey do:');
    disp(' ');
  disp('  oM = ipdfHSVOrientationMapping(ebsd_variable_name)')
  disp('  plot(oM)')
else
  property = get_option(varargin,'property','phase');
end

% phase plot
if ischar(property) && strcmpi(property,'phase')

  for k=1:numel(grains.phaseMap)
      
    ind = grains.phaseId == k;
    
    if ~any(ind), continue; end
    
    color = grains.subSet(ind).color;

    % plot polygons
    h{k} = plotFaces(grains.poly(ind),grains.V,color,...
      'parent', mP.ax,varargin{:}); %#ok<AGROW>

    lh{k} = h{k}(end);
    
    % reactivate legend information
    set(get(get(h{k}(end),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');      
    
  end
  
  idPlotted = unique(grains.phaseId);
  legend([lh{idPlotted}],grains.mineralList(idPlotted));

else % plot numeric property

  assert(numel(property) == length(grains) || numel(property) == length(grains)*3,...
    'The number of values should match the number of grains!')
  
  % plot polygons
  h = plotFaces(grains.poly,grains.V,property,...
    'parent', mP.ax,varargin{:});
  
end

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
