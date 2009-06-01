function plotxy(x,y,d,varargin)
% plot d along x and y


[x,y, lx,ly] = fixMTEXscreencoordinates(x,y,varargin);

%% get shape of plotting region
rx = unique(sort(x));
ry = unique(sort(y));
% 
rx = min(rx):min(diff(rx)):max(rx);
ry = min(ry):min(diff(ry)):max(ry);

nx = numel(rx); ny = numel(ry);

%% 
ix = round(1 + (x-min(rx)) ./(max(rx)-min(rx)) * (nx-1));
iy = round(1 + (y-min(ry)) ./(max(ry)-min(ry)) * (ny-1));

ix = max(min(nx,ix),1);
iy = max(min(ny,iy),1);

s = size(d);
c = nan(nx*ny,s(end));
c(iy + (ix-1)*ny,:) = d;%reshape(d,[],3);
c = reshape(c,ny,nx,s(end));

%%

if all(all(isnan(c(1:2:end,1:2:end,1)))) || ...
    all(all(isnan(c(1:2:end,2:2:end,1))))   
  
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
  
  [xx,yy] = meshgrid(rx,ry);
  c1 = griddata(x,y,d(:,1),xx,yy,'nearest');
  c2 = griddata(x,y,d(:,2),xx,yy,'nearest');
  c3 = griddata(x,y,d(:,3),xx,yy,'nearest');
  c = cat(3,c1,c2,c3);
  c = min(1,max(c,0));
end
  
%% plot

if size(c,3) == 1
  h = pcolor(rx,ry,c); shading flat 
else
  drx = diff(rx);
  dry = diff(ry);
  rx = [rx - [drx  drx(end)]/2   rx(end)+drx(end)/2];
  ry = [ry - [dry  drx(end)]/2   ry(end)+drx(end)/2];
  [rrx,rry] = meshgrid(rx,ry); 
  h = surf(rrx,rry,zeros(size(rrx)),c); shading flat 
  view(0,90);
end

optiondraw(h,varargin{:});

prepareMTEXplot;
xlabel(lx); ylabel(ly);
fixMTEXplot;

