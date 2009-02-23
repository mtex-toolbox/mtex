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

c = nan(nx*ny,3);
c(iy + (ix-1)*ny,:) = d;
c = reshape(c,ny,nx,3);

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
image(rx,ry,c)
axis equal tight

%% remove boundary from the figure
set(gcf,'units','pixel');
fig_pos = get(gcf,'position');
set(gca,'units','pixel');
d = get_option(varargin,'border',get_mtex_option('border',20));
a = pbaspect; a = a(1:2)./max(a(1:2));
b = (fig_pos(3:4) - 2*d);
c = b./a;
a = a * min(c);
set(gca,'position',[d d a]);
set(gcf,'position',[fig_pos(1:2) a+2*d]);
set(gcf,'units','normalized');
set(gca,'units','normalized');
