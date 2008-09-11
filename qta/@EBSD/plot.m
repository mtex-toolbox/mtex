function plot(ebsd,varargin)
% plots ebsd data
%
% this function is only a shortcut to EBSD/plotebsd

if isempty(ebsd.xy)
  plotebsd(ebsd,varargin{:});
else

  odf = calcODF(ebsd);
  q0 = modalorientation(odf);
  q = quaternion(getgrid(ebsd));
  
  %scatter(ebsd.xy(:,1),ebsd.xy(:,2),5,rotangle(q),'s','filled');
  d = quat2rgb(q,ebsd.CS,'q0',q0,varargin{:});
  
  %x = linspace(min(ebsd.xy(:,1)),max(ebsd.xy(:,1)),1000);
  %y = linspace(min(ebsd.xy(:,1)),max(ebsd.xy(:,1)),1000);
  %[x,y] = meshgrid(x,y);
  %c = griddata(ebsd.xy(:,1),ebsd.xy(:,2),d,x,y);
  %image(c);

  x = unique(sort(ebsd.xy(:,1)));
  y = unique(sort(ebsd.xy(:,2)));

  ix = round(1 + ebsd.xy(:,1) ./(max(x)-min(x)) * (numel(x)-1));
  iy = round(1 + ebsd.xy(:,2) ./(max(y)-min(y)) * (numel(y)-1));

  c = nan(numel(y)*numel(x),3);
  c(iy + (ix-1)*numel(y),:) = d;
  c = reshape(c,numel(y),numel(x),3);
  
  %pcolor(c);shading flat
  
  
  if   numel(find(isnan(c))) / numel(c) > 0.5
      
    [x,y] = meshgrid(x,y);
    c1 = griddata(ebsd.xy(:,1),ebsd.xy(:,2),d(:,1),x,y);
    c2 = griddata(ebsd.xy(:,1),ebsd.xy(:,2),d(:,2),x,y);
    c3 = griddata(ebsd.xy(:,1),ebsd.xy(:,2),d(:,3),x,y);
    c = cat(3,c1,c2,c3);
    c = min(1,max(c,0));
  end
  
  image(c)
  axis equal
  axis tight
  
end

function c = quat2rgb(q,cs,varargin)
% converts orientations to rgb values

q0 = get_option(varargin,'q0',idquaternion);
q = q(:)*inverse(q0);
qs = q*cs;
omega = rotangle(qs);

% find columns with minimum rotational angle
ind = omega == repmat(min(omega,[],2),1,length(cs));
ind = ind & ind == cumsum(ind,2);
omega = omega(ind);

if check_option(varargin,'logarithmic')
  omega = log(max(omega(:))/1000 + omega);
  omega = omega - min(omega);
end

disp(max(omega(:)));
omega = omega ./ max(omega(:));

a = reshape(double(rotaxis(q)),[],3);

%c = 0.5 + 0.5 * reshape(a,[],3) ./ max(abs(a(:))) .* [omega omega omega];

%a = 100*reshape(a./ max(abs(a(:))),[],3);
%c = double(Lab2RGB(20+omega*80,a(:,1),a(:,2)))./255;

pos = [[1;0;0] [-1;0;0] [0;1;0] [0;-1;0] [0;0;1] [0;0;-1]];
col = [[1,0,0];[1,1,0];[0,1,0];[0,1,1];[0,0,1];[1,0,1]];
  
c = zeros(numel(q),3);

for i = 1:6
  
  c(:,1) = c(:,1) + (acos(a * pos(:,i))).^2*col(i,1);
  c(:,2) = c(:,2) + (acos(a * pos(:,i))).^2*col(i,2);
  c(:,3) = c(:,3) + (acos(a * pos(:,i))).^2*col(i,3);
end

c = c ./ repmat(max(c,[],2),1,3);
c = rgb2hsv(c);
c(:,3) = ones(size(omega));
c(:,2) = omega;
c = hsv2rgb(c);  

