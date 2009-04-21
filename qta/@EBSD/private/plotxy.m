function plotxy(x,y,d,varargin)
% plot d along x and y

%% get shape of plotting region
rx = unique(sort(x));
ry = unique(sort(y));
nx = numel(rx); ny = numel(ry);

%% 
ix = round(1 + (x-min(rx)) ./(max(rx)-min(rx)) * (nx-1));
iy = round(1 + (y-min(ry)) ./(max(ry)-min(ry)) * (ny-1));
ix = max(min(nx,ix),1);
iy = max(min(ny,iy),1);

c = nan(nx*ny,size(d,3));
c(iy + (ix-1)*ny,:) = d;%reshape(d,[],3);
c = reshape(c,ny,nx,size(d,3));

%%

if all(all(isnan(c(1:2:end,1:2:end,1)))) || ...
    all(all(isnan(c(1:2:end,2:2:end,1)))) 
  
  
  c(2:end-1,2:end-1,:) = nanmedian(cat(4,...
    c(2:end-1,2:end-1,:),...
    c(1:end-2,2:end-1,:),c(3:end,2:end-1,:),...
    c(2:end-1,1:end-2,:),c(2:end-1,3:end,:)),4);
    
end

%% interpolate if necasarry
if check_option(varargin,'interpolate')  %numel(find(isnan(c))) / numel(c) > 0.5
  
  [xx,yy] = meshgrid(rx,ry);
  c1 = griddata(x,y,d(:,1),xx,yy,'nearest');
  c2 = griddata(x,y,d(:,2),xx,yy,'nearest');
  c3 = griddata(x,y,d(:,3),xx,yy,'nearest');
  c = cat(3,c1,c2,c3);
  c = min(1,max(c,0));
end
  
%% plot

dx = xvector; dy = yvector;
if appDataOption(varargin,'flipud',false), dy = -dy; end
if appDataOption(varargin,'fliplr',false), dx = -dx; end
rot = appDataOption(varargin,'rotate',0);
dx = axis2quat(zvector,rot) * dx;
dy = axis2quat(zvector,rot) * dy;

lx = 'x'; ly = 'y';
if isappr(dot(dx,xvector),0)
  c = permute(c,[2 1 3:ndims(c)]);
  [rx,ry] = swap(rx,ry);
  [dx,dy] = swap(dx,dy);
  [lx,ly] = swap(lx,ly);
end

if size(c,3) == 1
  pcolor(rx,ry,c);shading flat
else
  %image(rx,ry,c);
  [rrx,rry] = meshgrid(rx,ry);
  surf(rrx,rry,zeros(size(rrx)),c); shading flat
  view(0,90);
end

xlabel(lx); ylabel(ly);

if getx(dx) < 0, set(gca,'XDir','reverse'); else set(gca,'XDir','normal');end
if gety(dy) < 0, set(gca,'YDir','reverse'); else set(gca,'YDir','normal');end

axis equal tight


%% remove boundary from the figure
set(gcf,'units','pixel');
fig_pos = get(gcf,'position');
set(gca,'units','pixel');
d = get_option(varargin,'border',get_mtex_option('border',20));
a = pbaspect; a = a(1:2)./max(a(1:2));
b = (fig_pos(3:4) -30 - 2*d);
c = b./a;
a = a * min(c);
set(gca,'position',[30+d 30+d a]);
set(gcf,'position',[fig_pos(1:2) 30+a+2*d]);
set(gcf,'units','normalized');
set(gca,'units','normalized');



function v = appDataOption(options,token,default)

if isappdata(gcf,token)
  v = getappdata(gcf,token);
else
  if islogical(default)
    v = check_option(options,token);
  else
    v = get_option(options,token,default);
  end
  setappdata(gcf,token,v);
end

function [b,a] = swap(a,b)
