function plotGrains(grains,varargin)
% colorize grains
%
%% Syntax
% plotGrains(grains,'property','orientation') -
% plotGrains(grains,'property',get(grains,'phase')) -
%
%% Input
%  grains  - @Grain2d
%
%% Options
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
%% See also
% Grain3d/plotGrains

V = get(grains,'V');
boundaryEdgeOrder = get(grains,'boundaryEdgeOrder');

phaseMap = get(grains,'phaseMap');
phase    = get(grains,'phase');

% seperate measurements per phase
numberOfPhases = numel(phaseMap);
X = cell(1,numberOfPhases);
d = cell(1,numberOfPhases);

isPhase = false(numberOfPhases,1);
for k=1:numberOfPhases
  currentPhase = phase==phaseMap(k);
  isPhase(k)   = any(currentPhase);

  if isPhase(k)
    X{k} = boundaryEdgeOrder(currentPhase);
    [d{k},property,opts] = calcColorCode(grains,currentPhase,varargin{:});
  end
end

boundaryEdgeOrder = vertcat(X{:});

%% default plot options

varargin = set_default_option(varargin,...
  getpref('mtex','defaultPlotOptions'));

varargin = set_default_option(varargin,...
  {'name', [property ' plot of ' inputname(1) ' (' get(grains,'comment') ')']});

%%

% clear up figure
newMTEXplot('renderer','opengl',varargin{:});

% set direction of x and y axis

[V(:,1),V(:,2),lx,ly] = fixMTEXscreencoordinates(V(:,1),V(:,2),varargin{:});

xlabel(lx);ylabel(ly);

%%
h = plotFaces(boundaryEdgeOrder,V,vertcat(d{:}),varargin{:});

% make legend

if strcmpi(property,'phase'),

  F = get(grains,'F');
  F(any(F==0,2),:) = [];

  dummyV = min(V(F,:));

  % phase colormap
  lg = [];
  for k=1:numel(d)
    if ~isempty(d{k})

      lg = [lg patch('vertices',dummyV,'faces',[1 1],'FaceColor',d{k}(1,:))];
    end
  end
  minerals = get(grains,'minerals');
  legend(lg,minerals(isPhase));
end


% set appdata
if strncmpi(property,'orientation',11)
  CS = get(grains,'CSCell');
  setappdata(gcf,'CS',CS(isPhase));
  setappdata(gcf,'r',get_option(opts,'r',xvector));
  setappdata(gcf,'colorcenter',get_option(varargin,'colorcenter',[]));
  setappdata(gcf,'colorcoding',property(13:end));
end

set(gcf,'tag','ebsd_spatial');
setappdata(gcf,'options',[extract_option(varargin,'antipodal'),...
  opts varargin]);

fixMTEXscreencoordinates('axis'); %due to axis;

axis equal tight
fixMTEXplot(gca,varargin{:});



function h = plotFaces(boundaryEdgeOrder,V,d,varargin)

% add holes as polygons
hole = cellfun('isclass',boundaryEdgeOrder,'cell');

% split into holes an bounding
holeEdgeOrder = ...
  cellfun(@(x) x(2:end),boundaryEdgeOrder(hole),'UniformOutput',false);
boundaryEdgeOrder(hole) = ...
  cellfun(@(x) x{1},boundaryEdgeOrder(hole),'UniformOutput',false);

Polygons = [boundaryEdgeOrder(:)' holeEdgeOrder{:}];

d(numel(boundaryEdgeOrder)+1:numel(Polygons),: ) = 1;

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


