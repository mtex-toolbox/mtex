function slice3(ebsd,varargin)
% plot ebsd data as slices

%% Options
% slice  -  initial slice position in ebsd coordinates [x y z].
%
%% 
%

% make up new figure
newMTEXplot;

[sx,sy,sz] = addSlicer(varargin);

% x is allways east
plotx2east

% default plot options
varargin = set_default_option(varargin,...
  get_mtex_option('default_plot_options'));

% compute colorcoding
d = colorcode(ebsd,varargin{:});

% setup slicing planes
X = get(ebsd,'X');

if ~issorted(X(:,[3 2 1]),'rows')
  [Xt,m] = unique(X(:,[3 2 1]),'first','rows');
  d = d(m,:);
end

[dx,dy,dz] = estimateGridResolution(X(:,1),X(:,2),X(:,3));
ax = min(X); bx = max(X);

% z-slice
[u,v] = meshgrid(ax(1):dx:bx(1),ax(2):dy:bx(2));
[z,Fz,zgrid,s] = spatialdecomposition3d([u(:) v(:)]);
voxels(1:2) = s;

% y-slice
[u,v] = meshgrid(ax(1):dx:bx(1),ax(3):dz:bx(3));
[uv,Fy,ygrid,s] = spatialdecomposition3d([u(:) v(:)]);
y = [uv(:,1),uv(:,3),uv(:,2)];
voxels(3) = s(2);

% x-slice
[u,v] = meshgrid(ax(2):dy:bx(2),ax(3):dz:bx(3));
[uv,Fx,xgrid] = spatialdecomposition3d([u(:) v(:)]);
x = [uv(:,3),uv(:,1),uv(:,2)];

hz = patch('vertices',z,'faces',Fz,'edgecolor','none');
hy = patch('vertices',y,'faces',Fy,'edgecolor','none');
hx = patch('vertices',x,'faces',Fx,'edgecolor','none');

zparam.plane = 3;
zparam.grid = zgrid;
zparam.dim = voxels;
zparam.i = ax(3);
zparam.j = bx(3);
zparam.d = dz;

yparam.plane = 2;
yparam.grid = ygrid;
yparam.dim = voxels;
yparam.i = ax(2);
yparam.j = bx(2);
yparam.d = dy;

xparam.plane = 1;
xparam.grid = xgrid;
xparam.dim = voxels;
xparam.i = ax(1);
xparam.j = bx(1);
xparam.d = dx;



% handle callbacks
set(sz,'Callback',{@sliceIt,hz,zparam,d});
set(sy,'Callback',{@sliceIt,hy,yparam,d});
set(sx,'Callback',{@sliceIt,hx,xparam,d});


pos = get_option(varargin,'slice',mean([ax;bx]));
% initial slice positions
sliceIt(sz,[],hz,zparam,d,pos(3));
sliceIt(sy,[],hy,yparam,d,pos(2));
sliceIt(sx,[],hx,xparam,d,pos(1));

axis equal tight
grid on
view([30,15])



function sliceIt(e,v,slicingPlane,planeParam,cdata,pos)

if nargin < 6
  pos = planeParam.i+(planeParam.j-planeParam.i)*get(e,'value'); 
end

stack = round(pos/planeParam.d)+1;

% slicingPlane
p = get(slicingPlane,'Vertices');
p(:,planeParam.plane) = pos;

switch planeParam.plane
  case 1
    ndx = s2i3(planeParam.dim,stack,planeParam.grid(:,1),planeParam.grid(:,2));
  case 2
    ndx = s2i3(planeParam.dim,planeParam.grid(:,1),stack,planeParam.grid(:,2));
  case 3
    ndx = s2i3(planeParam.dim,planeParam.grid(:,1),planeParam.grid(:,2),stack);
end

cdata = cdata(ndx,:);
set(slicingPlane, 'Vertices',p);
set(slicingPlane,'FaceVertexCData',cdata,'FaceColor','flat');


function varargout = estimateGridResolution(varargin)

for k=1:numel(varargin)
  dx = diff(varargin{k});
  varargout{k} = min(dx(dx>0));
end

function [uv,VF,grid,sz] = spatialdecomposition3d(uv,varargin)

u = uv(:,1);
v = uv(:,2);
clear uv

% estimate grid resolution
du = get_option(varargin,'du',estimateGridResolution(u));
dv = get_option(varargin,'dv',estimateGridResolution(v));

% generate a tetragonal unit cell
iu = uint32(u/du);
iv = uint32(v/dv);
clear u v

lu = min(iu); lv = min(iv);
iu = iu-lu+1; iv = iv-lv+1;  % indexing of array
nu = max(iu); nv = max(iv);  % extend
sz = [nu,nv];

% new voxel coordinates
[vu,vv] = ind2sub(sz+1,(1:(nu+1)*(nv+1))');
uv = [double(vu+lu-1)*du-du/2,double(vv+lv-1)*dv-dv/2];
uv(:,3) = 0;

% % pointels incident to voxel
iun = iu+1; ivn = iv+1; % next voxel index
% pointels incident to voxels
VF = [s2i(sz+1,iu,iv)  s2i(sz+1,iun,iv)  s2i(sz+1,iun,ivn)  s2i(sz+1,iu,ivn)];

grid = [iu,iv];


function ndx = s2i(sz,i,j)
% faster version of sub2ind
ndx = 1 + (i-1) + (j-1)*sz(1);


function ndx = s2i3(sz,ix,iy,iz)
% faster version of sub2ind
ndx = 1 + (ix-1) + (iy-1)*sz(1) +(iz-1)*sz(1)*sz(2);


function d = colorcode(ebsd,varargin)

prop = lower(get_option(varargin,'property','orientation'));

if check_option(varargin,'phase') && ~strcmpi(prop,'phase') %restrict to a given phase
  ebsd(~ismember([ebsd.phase],get_option(varargin,'phase'))) = [];
end

% %% compute colorcoding
if isa(prop,'double')
  d = prop;
  prop = 'user';
end;

switch prop
  case 'user'
  case 'orientation'
    cc = lower(get_option(varargin,'colorcoding','ipdf'));
    d = [];
    for i = 1:length(ebsd)
      d = [d;orientation2color(ebsd(i).orientations,cc,varargin{:})];
    end
  case 'phase'
    d = [];
    for i = 1:length(ebsd)
      if numel(ebsd(i).phase == 1)
        d = [d;ebsd(i).phase * ones(sampleSize(ebsd(i)),1)]; %#ok<AGROW>
      elseif numel(ebsd(i).phase == 0)
        d = [d;nan(sampleSize(ebsd(i)),1)]; %#ok<AGROW>
      else
        d = [d,ebsd.phase(:)]; %#ok<AGROW>
      end
    end
    colormap(hsv(max(d)+1));
    %     co = get(gca,'colororder');
    %     colormap(co(1:length(ebsd),:));
  case fields(ebsd(1).options)
    d = get(ebsd,prop);
  otherwise
    error('Unknown colorcoding!')
end


function  [sx,sy,sz] = addSlicer(varargin)
slicetype = get_flag(varargin,{'x','y','z','xy','xz','yz','xyz'},'xyz');

fpos = -10;
if ~isempty(strfind(slicetype,'z'))
  fpos = fpos+20;
  sz = uicontrol(...
    'Units','pixels',...
    'BackgroundColor',[0.9 0.9 0.9],...   'Callback',{@sliceitz,x,y,z,Z},...        'Callback',{@(e,eb) sliceit(getappdata(gcbf,'slicedata'),get(e,'value'))},...
    'Position',[fpos 10 16 120],...
    'Style','slider',...
    'Tag','z');
  uicontrol('Position',[fpos 130 16 16],...
    'String','z','Style','text');
  %       uibutton('Position',[fpos 130 16 20],'String',labelz,'Interpreter','tex')
end

if ~isempty(strfind(slicetype,'y'))
  fpos = fpos+20;
  sy = uicontrol(...
    'Units','pixels',...
    'BackgroundColor',[0.9 0.9 0.9],...        'Callback',{@sliceity,x,y,z,Z},...         'Callback',{@(e,eb) sliceitY(getappdata(gcbf,'slicedata'),get(e,'value'))},...
    'Position',[fpos 10 16 120],...
    'Style','slider',...
    'Tag','y');
  uicontrol('Position',[fpos 130 16 16],...
    'String','y','Style','text');
  %     uibutton('Position',[fpos 130 16 20],'String',labely,'Interpreter','tex')
  
end

if ~isempty(strfind(slicetype,'x'))
  fpos = fpos+20;
  sx = uicontrol(...
    'Units','pixels',...
    'BackgroundColor',[0.9 0.9 0.9],...           'Callback',{@(e,eb) sliceitX(getappdata(gcbf,'slicedata'),get(e,'value'))},...
    'Position',[fpos 10 16 120],...
    'Style','slider',...
    'Tag','x');
  uicontrol('Position',[fpos 130 16 16],...
    'String','x','Style','text');
  %       uibutton('Position',[fpos 130 16 20],'String',labelx,'Interpreter','tex')
  
end

set(gcf,'Toolbar','figure')

