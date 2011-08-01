function slice3(ebsd,varargin)
% plot ebsd data as slices

%% options
% slice  -  initial slice position in ebsd coordinates [x y z].
%
%%
%

% make up new figure
newMTEXplot;

slicetype = get_flag(varargin,{'x','y','z','xy','xz','yz','xyz'},'xyz');
[sl, plane] = addslicer(slicetype,varargin{:});

% x is allways east
% plotx2east

% default plot options
varargin = set_default_option(varargin,...
  get_mtex_option('default_plot_options'));

% compute colorcoding
d = colorcode(ebsd,varargin{:});

% setup slicing planes
X = [ebsd.options.x(:),ebsd.options.y(:),ebsd.options.z(:)];

if ~issorted(X(:,[3 2 1]),'rows')
  [xt,m] = unique(X(:,[3 2 1]),'first','rows');
  d = d(m,:);
end

[dx,dy,dz] = estimateGridResolution(X(:,1),X(:,2),X(:,3));
ax = min(X); bx = max(X);
voxels = round((bx-ax)./[dx dy dz])+1;
 
pos = get_option(varargin,slicetype,mean([ax;bx]));

h = [];
% z-slice
if any(plane==3)
  sz = sl(plane==3);
  
  [u,v] = meshgrid(ax(1):dx:bx(1),ax(2):dy:bx(2));
  [z,fz,zgrid,s] = spatialdecomposition3d([u(:) v(:)]);
 
  h(end+1) = patch('vertices',z,'faces',fz,'edgecolor','none');
  zparam.plane = 3;
  zparam.grid = zgrid;
  zparam.dim = voxels;
  zparam.i = ax(3);
  zparam.j = bx(3);
  zparam.d = dz;
  
  set(sz,'callback',{@sliceit,h(end),zparam,d});
  sliceit(sz,[],h(end),zparam,d,pos(end));
end

% y-slice
if any(plane==2)
  sy = sl(plane==2);
  
  [u,v] = meshgrid(ax(1):dx:bx(1),ax(3):dz:bx(3));
  [uv,fy,ygrid,s] = spatialdecomposition3d([u(:) v(:)]);
  y = [uv(:,1),uv(:,3),uv(:,2)];
  
  h(end+1) = patch('vertices',y,'faces',fy,'edgecolor','none');  
  yparam.plane = 2;
  yparam.grid = ygrid;
  yparam.dim = voxels;
  yparam.i = ax(2);
  yparam.j = bx(2);
  yparam.d = dy;
  
  if any(strcmpi(slicetype,'x'))
    pp = pos(2);
  else
    pp = pos(1);
  end
  
  set(sy,'callback',{@sliceit,h(end),yparam,d});
  sliceit(sy,[],h(end),yparam,d,pp);
end

% x-slice
if any(plane==1)
  sx = sl(plane==1);
  
  [u,v] = meshgrid(ax(2):dy:bx(2),ax(3):dz:bx(3));
  [uv,fx,xgrid] = spatialdecomposition3d([u(:) v(:)]);
  x = [uv(:,3),uv(:,1),uv(:,2)];

  h(end+1) = patch('vertices',x,'faces',fx,'edgecolor','none');

  xparam.plane = 1;
  xparam.grid = xgrid;
  xparam.dim = voxels;
  xparam.i = ax(1);
  xparam.j = bx(1);
  xparam.d = dx;
  
  set(sx,'callback',{@sliceit,h(end),xparam,d});
  sliceit(sx,[],h(end),xparam,d,pos(1));
end



optiondraw(h,varargin{:});

axis equal
grid on
b = [ax(:)';bx(:)'];
axis(b(:)')
view([30,15])



function sliceit(e,v,slicingplane,planeparam,cdata,pos)

if nargin < 6
  pos = planeparam.i+(planeparam.j-planeparam.i)*get(e,'value');
end

stack = round(pos/planeparam.d)+1;

% slicingplane
p = get(slicingplane,'vertices');
p(:,planeparam.plane) = pos;

switch planeparam.plane
  case 1
    ndx = s2i3(planeparam.dim,stack,planeparam.grid(:,1),planeparam.grid(:,2));
  case 2
    ndx = s2i3(planeparam.dim,planeparam.grid(:,1),stack,planeparam.grid(:,2));
  case 3
    ndx = s2i3(planeparam.dim,planeparam.grid(:,1),planeparam.grid(:,2),stack);
end

cdata = cdata(ndx,:);
set(slicingplane, 'vertices',p);
set(slicingplane,'facevertexcdata',cdata,'facecolor','flat');


function varargout = estimateGridResolution(varargin)

for k=1:numel(varargin)
  dx = diff(varargin{k});
  varargout{k} = min(dx(dx>0));
end

function [uv,vf,grid,sz] = spatialdecomposition3d(uv,varargin)

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
vf = [s2i(sz+1,iu,iv)  s2i(sz+1,iun,iv)  s2i(sz+1,iun,ivn)  s2i(sz+1,iu,ivn)];

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
    
    d = ones(numel(ebsd),3);
    for p = unique(ebsd.phase).'
      if p == 0, continue;end
      ind = ebsd.phase == p;
      o = orientation(ebsd.rotations(ind),ebsd.CS{p},ebsd.SS);
      d(ind,:) = orientation2color(o,cc,varargin{:});
    end
    
    
  case 'angle'
    d = [];
    for i = 1:length(ebsd)
      d = [d; angle(ebsd(i).orientations)/degree];
    end
  case 'phase'
    d = [];
    for i = 1:length(ebsd)
      if numel(ebsd(i).phase == 1)
        d = [d;ebsd(i).phase * ones(samplesize(ebsd(i)),1)]; %#ok<agrow>
      elseif numel(ebsd(i).phase == 0)
        d = [d;nan(samplesize(ebsd(i)),1)]; %#ok<agrow>
      else
        d = [d,ebsd.phase(:)]; %#ok<agrow>
      end
    end
    colormap(hsv(max(d)+1));
    %     co = get(gca,'colororder');
    %     colormap(co(1:length(ebsd),:));
  case fields(ebsd(1).options)
    d = get(ebsd,prop);
  otherwise
    error('unknown colorcoding!')
end


function  [sz,plane] = addslicer(slicetype,varargin)

fpos = -10;
sz = [];
plane = [];
if ~isempty(strfind(slicetype,'z'))
  fpos = fpos+20;
  
  plane(end+1) = 3;
  
  sz(end+1) = uicontrol(...
    'units','pixels',...
    'backgroundcolor',[0.9 0.9 0.9],...   'callback',{@sliceitz,x,y,z,z},...        'callback',{@(e,eb) sliceit(getappdata(gcbf,'slicedata'),get(e,'value'))},...
    'position',[fpos 10 16 120],...
    'style','slider',...
    'tag','z');
  uicontrol('position',[fpos 130 16 16],...
    'string','z','style','text');
  %       uibutton('position',[fpos 130 16 20],'string',labelz,'interpreter','tex')
end

if ~isempty(strfind(slicetype,'y'))
  fpos = fpos+20;
  
  
  plane(end+1) = 2;
  
  sz(end+1) = uicontrol(...
    'units','pixels',...
    'backgroundcolor',[0.9 0.9 0.9],...        'callback',{@sliceity,x,y,z,z},...         'callback',{@(e,eb) sliceity(getappdata(gcbf,'slicedata'),get(e,'value'))},...
    'position',[fpos 10 16 120],...
    'style','slider',...
    'tag','y');
  uicontrol('position',[fpos 130 16 16],...
    'string','y','style','text');
  %     uibutton('position',[fpos 130 16 20],'string',labely,'interpreter','tex')
  
end

if ~isempty(strfind(slicetype,'x'))
  fpos = fpos+20;
  
  plane(end+1) = 1;
  
  sz(end+1) = uicontrol(...
    'units','pixels',...
    'backgroundcolor',[0.9 0.9 0.9],...           'callback',{@(e,eb) sliceitx(getappdata(gcbf,'slicedata'),get(e,'value'))},...
    'position',[fpos 10 16 120],...
    'style','slider',...
    'tag','x');
  uicontrol('position',[fpos 130 16 16],...
    'string','x','style','text');
  %       uibutton('position',[fpos 130 16 20],'string',labelx,'interpreter','tex')
  
end

set(gcf,'toolbar','figure')

