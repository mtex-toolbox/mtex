function varargout = slice3(ebsd,varargin)
% slice through 3d EBSD data
%
% for colorcoding plee see [[EBSD.plotspatial.html,plotspatial]]
%
% Input
%  ebsd - @EBSD
% Flags
%  x|y|z|xy|xyz - specifiy a slicing plane
%  dontFill - do not colorize the interior of a grain
% See also
% Grain3d/slice3 EBSD/plotspatial


% make up new figure
newMTEXplot;

opts = parseArgs(varargin{:});

api = getGridApi(ebsd,varargin{:});
api = getSliceApi(api,opts);


xlabel('x')
ylabel('y')
zlabel('z')

box on
grid on
view(3)

range = reshape([...
  api.Grid.Xmin-api.Grid.dX/2; ...
  api.Grid.Xmax+api.Grid.dX/2],1,[]);

axis ('equal',range);

if isfield(api,'CDataLim')
  set(gca,'CLim',api.CDataLim);
end

optiondraw([api.Slicer.hSurf],varargin{:});
set([api.Slicer.hSurf],'Visible','on')


% make legend
if strcmpi(api.ColorCode,'phase')
  minerals = get(ebsd,'minerals');
  legend(minerals(api.isPhase));
end


% set appdata
if strncmpi(api.ColorCode,'orientation',11)
  setappdata(gcf,'CS',ebsd.CS(api.isPhase));
  setappdata(gcf,'CCOptions',opts(api.isPhase));
  setappdata(gcf,'colorcoding',api.ColorCode(13:end));
end

set(gcf,'tag','ebsd_slice3');

set(gcf,'toolbar','figure')


if nargout > 0
  varargout{1} = [api.Slicer.hSlider];
end

function opts = parseArgs(varargin)

c = varargin(cellfun('isclass',varargin,'char'));

sliceType = '';
slicePos   = [];

for k=1:numel(c)
  if all(ismember(double(c{k}),double('xyz')))
    sliceP = get_option(varargin,c{k},[],'double');
    if numel(sliceP) ~= numel(c{k})
      error('Number of slice positions must agree with number of desired slices');
    else
      sliceType = [sliceType c{k}];
      slicePos  = [slicePos  sliceP];
    end
  end
end

if isempty(slicePos)
  sliceType = 'xyz';
  slicePos  = [NaN NaN NaN];
end

opts.sliceType = sliceType;
opts.slicePos  = slicePos;

hide = {'on','off'};
opts.hideSlider  = hide{1+check_option(varargin,{'hideSlider','hideSliders'})};


function api = getGridApi(ebsd,varargin)

% get pixels
X = [ebsd.prop.x(:), ebsd.prop.y(:), ebsd.prop.z(:)];

Xmin = min(X);
Xmax = max(X);

% if unitcell is missing
if isempty(ebsd.unitCell)
  dX = [median(diff(unique(X(:,1)))) ...
    median(diff(unique(X(:,2)))) ...
    median(diff(unique(X(:,3))))];
else
  dX = abs(2*ebsd.unitCell([1 13 17]));
end

% compute colorcoding
numberOfPhases = numel(ebsd.phaseMap);
isPhase = false(numberOfPhases,1);
d = [];

% what to plot
prop = get_option(varargin,'property','orientations',{'char','double'});

for k=1:numberOfPhases
  iP = ebsd.phase==k;
  isPhase(k) = any(iP);
  
  [d(iP,:),property] = calcColorCode(ebsd,iP,prop,varargin{:});
end

% grid coordinates
iX = 1 + round(bsxfun(@rdivide,bsxfun(@minus,X,Xmin),dX));
sz = max(iX);

ndx = @(iX,iY,iZ) 1 + (iX-1) + (iY-1)*sz(1) +(iZ-1)*sz(1)*sz(2);
% fill missing colors upon grid
api.ColorCode = property;
api.isPhase   = isPhase;

CData         = NaN(prod(sz),size(d,2));
CData(ndx(iX(:,1),iX(:,2),iX(:,3)),:) = d;

api.CDataDim  = @(dim1,dim2) [sz([dim1 dim2]) size(CData,2)];
api.CData     = @(iX,iY,iZ) CData(ndx(iX,iY,iZ),:);

if size(d,2) == 1
  api.CDataLim  = [min(d) max(d)];
end

grid.Xmin     = Xmin;
grid.Xmax     = Xmax;
grid.dX       = dX;
% grid.Voxels   = sz;

% dG       = @(i) (Xmin(i)-dX(i)/2):dX(i):(Xmax(i)+dX(i)/2);
dG       = @(i) linspace(Xmin(i)-dX(i)/2,Xmax(i)+dX(i)/2,sz(i)+1);

% surf coordiantes
grid.meshSliceByDim = @(dim1,dim2) meshgrid(dG(dim1),dG(dim2),1);
% surf indices
grid.meshVoxelByDim = @(dim1,dim2) meshgrid(1:sz(dim1),1:sz(dim2));

iX = @(p,d) interPos(p,Xmax(d),Xmin(d),dX(d),sz(d));
pX = @(p,d) interLim(p,Xmin(d)-dX(d)./2,Xmax(d)+dX(d)./2);

% dimension  % percentage
grid.iX       = @(p) iX(p,1); % indexing
grid.pX       = @(p) pX(p,1); % position

grid.iY       = @(p) iX(p,2); % indexing
grid.pY       = @(p) pX(p,2); % position

grid.iZ       = @(p) iX(p,3); % indexing
grid.pZ       = @(p) pX(p,3); % position

api.Grid     = grid;


function api = getSliceApi(api,opts)

washold = getHoldState;
hold all
for k=1:numel(opts.sliceType)
  
  api.Slicer(k) = localAddSlicer(opts.sliceType(k),opts.slicePos(k),opts.hideSlider,api);
  
end

hold(washold)


function Slicer = localAddSlicer(sliceType,slicePos,hideSlider,api)


sliderPosX    = 10;
sliderOffsetX = 20;

hOldSlices = findall(gcf,'tag','slicer');
if ~isempty(hOldSlices)
  oldSlicerPos = ensurecell(get(hOldSlices,'position'));
  sliderPosX = max(cellfun(@(x) x(1),oldSlicerPos))+sliderOffsetX;
end

hSlider = uicontrol(...
  'units','pixels',...
  'backgroundcolor',[0.9 0.9 0.9],...
  'position',[sliderPosX 10 16 120],...
  'tag','slicer',...
  'visible',hideSlider,...
  'style','slider');

hLabel  = uicontrol('position',[sliderPosX 130 16 16],...
  'string',sliceType,...
  'visible',hideSlider,...
  'style','text');

dim = find(strcmp(lower(sliceType),{'x','y','z'}));
step = 1/(((api.Grid.Xmax(dim)-api.Grid.Xmin(dim))./api.Grid.dX(dim))+2);

if ~isfinite(slicePos)
  slicePos = (api.Grid.Xmax(dim)+api.Grid.Xmin(dim))/2;
end

set(hSlider,...
  'Min',api.Grid.Xmin(dim)-api.Grid.dX(dim)/2,...
  'Max',api.Grid.Xmax(dim)+api.Grid.dX(dim)/2,...
  'Value',slicePos,...
  'SliderStep',[step .1]);

Slicer = feval(['localAdd' upper(sliceType) 'Slice'],api);
Slicer.hSlider = hSlider;
Slicer.hLabel  = hLabel;

localAddSliceCallback(Slicer,slicePos);


function localAddSliceCallback(Slicer,slicePos)

set(Slicer.hSlider,...
  'Value',slicePos,...
  'Callback',{@localSliceCallback,Slicer});

localSliceCallback([],[],Slicer);


function localSliceCallback(event,source,Slicer)

p = get(Slicer.hSlider,'Value');

set(Slicer.hSurf,'CData',Slicer.getSliceCData(p));
set(Slicer.hSurf,Slicer.dim,Slicer.getSlicePos(p));


function Slicer = localAddXSlice(api)

grd = api.Grid;

[z,y,x] = grd.meshSliceByDim(3,2);
[iZ,iY] = grd.meshVoxelByDim(3,2);

Slicer.getSliceCData = @(pos) reshape(api.CData(grd.iX(pos),iY,iZ),api.CDataDim(2,3));
Slicer.getSlicePos   = @(pos) x*grd.pX(pos);

Slicer.dim = 'XData';

Slicer.hSurf = surf(...
  Slicer.getSlicePos(0),y,z,...
  Slicer.getSliceCData(0),...
  'EdgeColor','none',...
  'Visible','off');


function Slicer = localAddYSlice(api)

grd = api.Grid;

[z,x,y] = grd.meshSliceByDim(3,1);
[iZ,iX] = grd.meshVoxelByDim(3,1);

Slicer.getSliceCData = @(pos) reshape(api.CData(iX,grd.iY(pos),iZ),api.CDataDim(1,3));
Slicer.getSlicePos   = @(pos) y*grd.pY(pos);

Slicer.dim = 'YData';

Slicer.hSurf = surf(...
  x,Slicer.getSlicePos(0),z,...
  Slicer.getSliceCData(0),...
  'EdgeColor','none',...
  'Visible','off');



function Slicer = localAddZSlice(api)

grd = api.Grid;

[y,x,z] = grd.meshSliceByDim(2,1);
[iY,iX] = grd.meshVoxelByDim(2,1);

Slicer.getSliceCData = @(pos) reshape(api.CData(iX,iY,grd.iZ(pos)),api.CDataDim(1,2));
Slicer.getSlicePos   = @(pos) z*grd.pZ(pos);

Slicer.dim = 'ZData';

Slicer.hSurf = surf(...
  x,y,Slicer.getSlicePos(0),...
  Slicer.getSliceCData(0),...
  'EdgeColor','none',...
  'Visible','off');


function y = interPos(x,xmax,xmin,dx,sz)

y = floor(1+(x+dx/2-xmin)./(xmax-xmin+dx)*sz);

if (y < 1)
  y = 1;
elseif (y > sz)
  y = sz;
end


function y = interLim(x,xmin,xmax)

if x < xmin
  y = xmin;
elseif x > xmax
  y = xmax;
else
  y = x;
end
