function plot(ebsd,varargin)
% plots ebsd data
%
% this function is only a shortcut to EBSD/plotebsd

if isempty(ebsd.xy)
  plotebsd(ebsd,varargin{:});
else

  if check_option(varargin,'centered')
    odf = calcODF(ebsd);
    q0 = modalorientation(odf);
  else
    q0 = idquaternion;
  end
  q = quaternion(getgrid(ebsd));
  
  %scatter(ebsd.xy(:,1),ebsd.xy(:,2),5,rotangle(q),'s','filled');
  switch get_option(varargin,'colorcoding','')
    case 'Bunge'
      d = euler2rgb(q,ebsd.CS,ebsd.SS,'q0',q0,varargin{:});
    case 'ANGLE'
      d = quat2rgb(q,ebsd.CS,ebsd.SS,'q0',q0,varargin{:});
    otherwise
      d = sigma2rgb(q,ebsd.CS,ebsd.SS,'q0',q0,varargin{:});
  end
  
  %x = linspace(min(ebsd.xy(:,1)),max(ebsd.xy(:,1)),1000);
  %y = linspace(min(ebsd.xy(:,1)),max(ebsd.xy(:,1)),1000);
  %[x,y] = meshgrid(x,y);
  %c = griddata(ebsd.xy(:,1),ebsd.xy(:,2),d,x,y);
  %image(c);

  x = unique(sort(ebsd.xy(:,1)));
  y = unique(sort(ebsd.xy(:,2)));

  ix = round(1 + (ebsd.xy(:,1)-min(x)) ./(max(x)-min(x)) * (numel(x)-1));
  iy = round(1 + (ebsd.xy(:,2)-min(y)) ./(max(y)-min(y)) * (numel(y)-1));
  ix = max(min(numel(x),ix),1);
  iy = max(min(numel(y),iy),1);

  c = nan(numel(y)*numel(x),3);
  c(iy + (ix-1)*numel(y),:) = d;
  c = reshape(c,numel(y),numel(x),3);
  
  %pcolor(c);shading flat
  

  if   numel(find(isnan(c))) / numel(c) > 0.5
    
    [xx,yy] = meshgrid(x,y);
    c1 = griddata(ebsd.xy(:,1),ebsd.xy(:,2),d(:,1),xx,yy);
    c2 = griddata(ebsd.xy(:,1),ebsd.xy(:,2),d(:,2),xx,yy);
    c3 = griddata(ebsd.xy(:,1),ebsd.xy(:,2),d(:,3),xx,yy);
    c = cat(3,c1,c2,c3);
    c = min(1,max(c,0));
  end
  
  image(x,y,c)
  axis equal tight
  % axis xy
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

function c = euler2rgb(q,cs,varargin)
% converts orientations to rgb values

q0 = get_option(varargin,'q0',idquaternion);
q = q(:)*inverse(q0);
[phi1,Phi,phi2] = quat2euler(q,'Bunge');

phi1 = mod(-phi1,pi/2) *2 ./ pi;
Phi = mod(-Phi,pi/2); Phi = Phi./max(Phi(:));
phi2 = mod(-phi2,pi/2)*2 ./ pi;

c = [phi1(:),Phi(:),phi2(:)];


function c = sigma2rgb(q,cs,ss,varargin)
% converts orientations to rgb values

q0 = get_option(varargin,'q0',idquaternion);
q = q(:)*inverse(q0);
[phi1,Phi,phi2] = quat2euler(q,'Bunge');

[maxphi1,maxPhi,maxphi2] = getFundamentalRegion(cs,ss);

s1 = mod(phi2-phi1,maxphi1) ./ maxphi1;
Phi = mod(-Phi,maxPhi); Phi = Phi./max(Phi(:));
s2 = mod(phi1+phi2,maxphi2)./ maxphi2;

c = [s1(:),Phi(:),s2(:)];
