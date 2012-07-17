function h = plotxy(xy,d,varargin)
% plot d along x and y


[x,y, lx,ly] = fixMTEXscreencoordinates(xy(:,1),xy(:,2),varargin{:});

%% estimate grid resolution

rndsmp = [ (1:sum(1:length(x)<=75))'; unique(fix(1+rand(200,1)*(length(x)-1)))];

xx = repmat(x(rndsmp),1,length(rndsmp));
yy = repmat(y(rndsmp),1,length(rndsmp));
dist = abs(sqrt((xx-xx').^2 + (yy-yy').^2));

dxy = min(dist(dist>0));

%% generate a grid

rx = min(x)-dxy/2:dxy:max(x)+dxy;
ry = min(y)-dxy/2:dxy:max(y)+dxy;

[xx,yy] = meshgrid(rx,ry); 

nx = numel(rx); ny = numel(ry);

%% 
ix = fix(1 + (x-rx(1))/dxy); 
iy = fix(1 + (y-ry(1))/dxy);

s = size(d);
c = NaN(nx*ny,s(end));
c(iy + (ix-1)*ny,:) = d;
c = reshape(c,ny,nx,s(end));

%%

if 4*sum(isnan(c(:)))>sum(~isnan(c(:))) && all(size(c(:,:,1)) > 2)
  
  cc = cat(4,...
    c(2:end-1,2:end-1,:),...
    c(1:end-2,2:end-1,:),c(3:end,2:end-1,:),...
    c(2:end-1,1:end-2,:),c(2:end-1,3:end,:));
  
  d = nanmedian(cc,4);
  d(sum(isnan(cc(:,:,1,:)),4)>=3 & isnan(cc(:,:,1,1))) = NaN;
  c(2:end-1,2:end-1,:) = d;
  
end

%% interpolate if necasarry
if check_option(varargin,'interpolate')  %numel(find(isnan(c))) / numel(c) > 0.5
  
  c1 = griddata(x,y,d(:,1),xx,yy,'nearest');
  c2 = griddata(x,y,d(:,2),xx,yy,'nearest');
  c3 = griddata(x,y,d(:,3),xx,yy,'nearest');
  c = cat(3,c1,c2,c3);
  c = min(1,max(c,0));
end
  
%% plot

if size(c,3) == 1
  h = pcolor(xx,yy,c); shading flat 
else
  h = surf(xx,yy,zeros(size(xx)),c); shading flat 
  view(0,90);
end

optiondraw(h,varargin{:});

xlabel(lx); ylabel(ly);
fixMTEXplot;
