function varargout = slice3(ebsd,varargin)
% slice through 3d EBSD data
%
% for colorcoding plee see [[EBSD.plotspatial.html,plotspatial]]
%
%% Input
% ebsd - @EBSD
%% Flags
% x|y|z|xy|xyz - specifiy a slicing plane
% dontFill - do not colorize the interior of a grain
%% See also
% Grain3d/slice3 EBSD/plotspatial


% make up new figure
newMTEXplot;

sliceType = get_flag(varargin,{'x','y','z','xy','xz','yz','xyz'},'xyz');
slicePos  = get_option(varargin,sliceType,[.5 .5 .5],'double');
hSlicer   = addSlicer(sliceType,varargin{:});

if numel(slicePos)<=numel(sliceType)
  slicePos(1:numel(sliceType)) = slicePos(1);
end

% x is allways east
% plotx2east

% get pixels
X = [ebsd.options.x(:) ebsd.options.y(:) ebsd.options.z(:)];
Xmin = min(X); Xmax = max(X);

dX = abs(2*ebsd.unitCell([1 13 17]));

% grid coordinates
iX = round(bsxfun(@rdivide,X,dX));
iX = 1+bsxfun(@minus,iX,min(iX));

sz = max(iX);

% compute colorcoding
d = [];
for k=1:numel(ebsd.phaseMap)
  iP = ebsd.phase==k;
  [d(iP,:),property] = calcColorCode(ebsd,iP,varargin{:});
end

% fill colorcoding upon grid
l = sparse(s2i3(sz,iX(:,1),iX(:,2),iX(:,3)),1,true,prod(sz),1);
d(l,:) = d;
d(~l,:)= NaN;

% construct slicing planes
g = @(i) linspace(Xmin(i),Xmax(i),sz(i));

obj = struct; plane = struct; n = 0;

if any(sliceType == 'x')
  n = n+1;
  % patch object
  [x,y,z] = meshgrid(0,g(2),g(3));
  [obj(n).Vertices(:,[2 3]) obj(n).Faces] = generateUnitCells([y(:) z(:)],ebsd.unitCell(9:end,:),varargin{:});
  % color&pos-fun
  [xi,yi,zi] = meshgrid(0,1:sz(2),1:sz(3));
  plane(n).fun = @(p) d(s2i3(sz,interp(p,sz(1)),yi,zi),:);
  plane(n).pos = @(p) interlim(p,Xmin(1)-dX(1)./2,Xmax(1)+dX(1)./2);
  plane(n).dim = 1;
end

if any(sliceType == 'y')
  n = n+1;
  % patch object
  [x,y,z] = meshgrid(g(1),0,g(3));
  [obj(n).Vertices(:,[1 3]) obj(n).Faces] = generateUnitCells([x(:) z(:)],ebsd.unitCell(5:8,:),varargin{:});
  % color&pos-fun
  [xi,yi,zi] = meshgrid(1:sz(1),0,1:sz(3));
  plane(n).fun = @(p) d(s2i3(sz,xi,interp(p,sz(2)),zi),:);
  plane(n).pos = @(p) interlim(p,Xmin(2)-dX(2)./2,Xmax(2)+dX(2)./2);
  plane(n).dim = 2;
end

if any(sliceType == 'z')
  n = n+1;
  % patch object
  [x,y,z] = meshgrid(g(1),g(2),0);
  [obj(n).Vertices(:,1:2)   obj(n).Faces] = generateUnitCells([x(:) y(:)],ebsd.unitCell(1:4,:),varargin{:});
  % color&pos-fun
  [xi yi] = meshgrid(1:sz(1),1:sz(2));
  plane(n).fun = @(p) d(s2i3(sz,xi,yi,interp(p,sz(3))),:);
  plane(n).pos = @(p) interlim(p,Xmin(3)-dX(3)./2,Xmax(3)+dX(3)./2);
  plane(n).dim = 3;
end


for k=1:numel(obj)
  obj(k).FaceColor = 'flat';
  obj(k).EdgeColor = 'none';
  h(k) = patch(obj(k));

  set(hSlicer(k),...
    'value',slicePos(k),...
    'callback',{@sliceIt,h(k),plane(k)});

  sliceIt(hSlicer(k),[],h(k),plane(k))
end



optiondraw(h,varargin{:});
axis equal
axlim = [Xmin(:)-dX(:)./2 Xmax(:)+dX(:)./2]';
axis (axlim(:))
grid on
view([30,15])


if size(d,2) == 1
  set(gca,'CLim',[min(d) max(d)]);
end


% make legend

if strcmpi(property,'phase'),
  % phase colormap
  minerals = get(ebsd,'minerals');

  isPhase = ismember(unique(d),ebsd.phaseMap);
  phaseMap = ebsd.phaseMap;
  for k=1:numel(phaseMap)
    lg(k) = patch('vertices',[0 0],'faces',[1 1],'FaceVertexCData',phaseMap(k),'facecolor','flat')
  end
  set(gca,'CLim',[min(d) max(d)+1]);
  colormap(hsv(numel(phaseMap)));
  legend(lg,minerals(isPhase),'Location','NorthEast');
end

% set appdata
if strcmpi(property,'orientation') %&& strcmpi(cc,'ipdf')
  setappdata(gcf,'CS',ebsd.CS)
  setappdata(gcf,'r',get_option(varargin,'r',xvector,'vector3d'));
  setappdata(gcf,'colorcenter',get_option(varargin,'colorcenter',[]));
  setappdata(gcf,'colorcoding',lower(get_option(varargin,'colorcoding','ipdf')));
end

set(gcf,'tag','ebsd_slice3');
setappdata(gcf,'options',extract_option(varargin,'antipodal'));


if nargout > 0
  varargout{1} = hSlicer;
end


function sliceIt(ev,v,hSlicer,plane)

p = get(ev,'value');
z = get(hSlicer,'Vertices');

z(:,plane.dim) = plane.pos(p);
set(hSlicer,'Vertices',z);
set(hSlicer,'FaceVertexCData',plane.fun(p));


function ndx = s2i3(sz,ix,iy,iz)
% faster version of sub2ind
ndx = 1 + (ix-1) + (iy-1)*sz(1) +(iz-1)*sz(1)*sz(2);


function y = interp(x,sz)

if x <= 0
  y = ones(size(sz));
elseif x > 1
  y = sz;
else
  y = ceil(x.*sz);
end

function y = interlim(x,xmin,xmax)

if x<=0
  y = xmin;
elseif x>1
  y = xmax;
else
  y = x.*(xmax-xmin)+xmin;
end


function  hSlicer = addSlicer(sliceType,varargin)

fpos = -10;

if strcmpi(get(gcf,'tag'),'ebsd_slice3')
  hSliders = findall(gcf,'Style','slider');
  fpos = max(cellfun(@(x) x(1),ensurecell(get(hSliders,'position'))))+10;
else
  fpos = -10;
end

for k=1:numel(sliceType)

  fpos = fpos+20;

  hSlicer(k) = uicontrol(...
    'units','pixels',...
    'backgroundcolor',[0.9 0.9 0.9],...   'callback',{@sliceitz,x,y,z,z},...        'callback',{@(e,eb) sliceit(getappdata(gcbf,'slicedata'),get(e,'value'))},...
    'position',[fpos 10 16 120],...
    'style','slider');
  uicontrol('position',[fpos 130 16 16],...
    'string',sliceType(k),'style','text');

end

set(gcf,'toolbar','figure')




