function plotGrains(grains,varargin)
% colorize grains
%
% Syntax
%   plotGrains(grains) % colorize by mean orientatation
%   plotGrains(grains,'property','phase') % 
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

V = grains.V;
boundaryEdgeOrder = grains.boundaryEdgeOrder;

% seperate measurements per phase
numberOfPhases = numel(grains.phaseMap);
X = cell(1,numberOfPhases);
d = cell(1,numberOfPhases);

% what to plot
prop = get_option(varargin,'property','meanOrientation',{'char','double'});

isPhase = false(numberOfPhases,1);
for p=1:numberOfPhases
  currentPhase = grains.phase==p;
  isPhase(p)   = any(currentPhase);

  if isPhase(p)
    X{p} = boundaryEdgeOrder(currentPhase);
    [d{p},property,opts] = calcColorCode(grains,currentPhase,prop,varargin{:});
  end
end

boundaryEdgeOrder = vertcat(X{:});

% ensure all data have the same size
dim2 = cellfun(@(x) size(x,2),d);

if numel(unique(dim2)) > 1
  for k = 1:numel(d)
    if dim2(k)>0
      d{k} = repmat(d{k},[1,max(dim2)/dim2(k)]);
    end
  end
end


% default plot options

% varargin = set_default_option(varargin,...
%   {'name', [property ' plot of ' inputname(1) ' (' get(grains,'comment') ')']});

%

% clear up figure
newMTEXplot('renderer','opengl',varargin{:});
setCamera(varargin{:});

% set direction of x and y axis
xlabel('x');ylabel('y');

%
%d = vertcat(d{:});
%[ud,m,n] = unique(d);
%h = [];
%if numel(ud) < 20 && numel(ud) > 1
%  for i = 1:numel(ud)
%    h = [h,plotFaces(boundaryEdgeOrder(n==i),V,d(n==i),varargin{:})];
%  end
%else
h = plotFaces(boundaryEdgeOrder,V,vertcat(d{:}),varargin{:});
%end

% remove them from legend
arrayfun(@(x) set(get(get(x,'Annotation'),'LegendInformation'),...
    'IconDisplayStyle','off'),h);

% make legend

if strcmpi(property,'phase'),
  
  F = grains.F;
  F(any(F==0,2),:) = [];

  dummyV = min(V(F,:));

  % phase colormap
  lg = [];
  for k=1:numel(d)
    if ~isempty(d{k})

      lg = [lg patch('vertices',dummyV,'faces',[1 1],'FaceColor',d{k}(1,:))];
    end
  end
  legend(lg,grains.minerals(isPhase),'location','NorthEast');
end


% set appdata
if strncmpi(property,'orientation',11)
  setappdata(gcf,'CS',grains.CS(isPhase));
  setappdata(gcf,'r',get_option(opts,'r',xvector));
  setappdata(gcf,'colorcenter',get_option(varargin,'colorcenter',[]));
  setappdata(gcf,'colorcoding',property(13:end));
end

set(gcf,'tag','ebsd_spatial');
setappdata(gcf,'options',[extract_option(varargin,'antipodal'),...
  opts varargin]);

axis equal tight
fixMTEXplot(gca,varargin{:});

% set data cursor
if ~isOctave()
  
  dcm_obj = datacursormode(gcf);
  set(dcm_obj,'SnapToDataVertex','off')
  set(dcm_obj,'UpdateFcn',{@tooltip,grains});

  datacursormode on;
end

% Tooltip function
function txt = tooltip(empt,eventdata,grains) %#ok<INUSL>


[pos,value] = getDataCursorPos(gcf);
try
  sub = findByLocation(grains,[pos(1) pos(2)]);
catch
  sub = [];
end

if numel(sub)>0

  [ebsd_id,grain_id] = find(get(sub,'I_DG')); %#ok<ASGLU>
  minerals = get(sub,'minerals');

  txt{1} = ['Grain: '  num2str(unique(grain_id))];
  txt{2} = ['Phase: ', minerals{get(sub,'phaseMap') == get(sub,'phase')}];
  if ~isNotIndexed(sub)
    txt{3} = ['Orientation: ' char(get(sub,'orientation'),'nodegree')];
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

% how to colorize holes 
% d(numel(boundaryEdgeOrder)+1:numel(Polygons),: ) = 1;
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


