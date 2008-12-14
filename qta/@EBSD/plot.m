function plot(ebsd,varargin)
% plots ebsd data
%
% this function is a shortcut to EBSD/plotebsd if xy-coordinates are not
% valid
%
%% Input
% ebsd - @EBSD
%
%% Options
%
% CENTERED     - centered by odf
%
% BUNGE        - colors after Bunge convention
% IHS          - transform Bunge into IHS/HSV
% ANGLE        - quaternion coloring
% WHITE        - NaNs get transparent (black is default)
%
% 'DATA'       - plot optional data
%    COLORMAP     - set up colormap for 'DATA' 
%    COLORMAPSIZE - scaling parameter 
%
% INTERPOLATE  - 'nearest', 'linear', 'cubic'
%
% GRAINS       - plot grains by id, (default) random color
%    MEAN      - plot mean of grains
%    COLORMAP  - color grainids by given colormap
%
% NOSCALE      - prevent from reseting axis, useful for subplot
% 
%% Examples
% 
% plot(ebsd)
% plot(ebsd,'bunge')
%
% ax(1) = subplot(3,1,1);
% plot(ebsd,'IHS','noscale');
% ax(2) = subplot(3,1,2);
% plot(ebsd,'BC','colormap',hsv(256),'colormapsize',236,'noscale');
% ax(3) = subplot(3,1,3);
% plot(ebsd,'grains','mean','ihs','noscale');
% linkaxes(ax(1:3),'xy');
%
if size(cell2mat(ebsd.xy),1) ~= sum(GridLength(ebsd.orientations))
  plotebsd(ebsd,varargin{:});
else
  xy = cell2mat(ebsd.xy);
  x = unique(xy(:,1));
  y = unique(xy(:,2));
  
  if check_option(varargin,'centered')
    odf = calcODF(ebsd);
    q0 = modalorientation(odf);
  else
    q0 = idquaternion;
  end
  q = quaternion(getgrid(ebsd));  
   
	if check_option(varargin,'grains')
    if isempty(ebsd.grainid), warning('matlab:EBSD:noGrains',['grain segmentation not done, try \n ' inputname(1) ' = segment(' inputname(1) ')']);return; end
  
    q = cell2mat(ebsd.grainid);
    
    if check_option(varargin,'colormap');
      d = calc_color_ind(q,varargin{:});
    else
      ids = unique(q);
      
      d = zeros(length(xy),3);
      if check_option(varargin,'mean');
        cs = [0, cumsum(length(ebsd))];
        for i=1:length(ids)
          id = find(q == ids(i));          
          gr = numel(ebsd) - sum(id(1) <= cs) + 1;
          eb = subsref(ebsd,substruct('()',{gr,id-cs(gr)}));
        
          m = mean(eb);
          
          ebcs = getCSym(eb.orientations); ebss = getSSym(eb.orientations);
          if check_option(varargin,'bunge')
            f = euler2rgb(m,varargin);
          elseif check_option(varargin,'ihs')  
            f = euler2rgb(m,varargin);
            f = rgb2hsv(f);
          elseif check_option(varargin,'angle')
            f = quat2rgb(m,ebcs,ebss,varargin);
          else
            f = sigma2rgb(m,ebcs,ebss,varargin);
          end   
          d(id,:) = repmat(f,length(id),1);
        end
      else
        for i=1:length(ids)
          id = find(q == ids(i));
          d(id,:) = repmat(rand(1,3),length(id),1);
        end
      end
    end    
  elseif check_option(varargin,'bunge')
    d = euler2rgb(q,'q0',q0,varargin{:});
  elseif check_option(varargin,'ihs')  
    d = euler2rgb(q,'q0',q0,varargin{:});
    d = rgb2hsv(d);
  elseif check_option(varargin,'angle')
    d = calc_color(@quat2rgb,ebsd,'q0',q0,varargin{:});
  elseif check_option(varargin,'phase')
    q = [];
    for i=1:numel(ebsd),
      q = [q ;repmat(ebsd.phase(i),GridLength(ebsd.orientations(i)),1)]; end
   
    d = calc_color_ind(q,varargin{:});
  elseif check_option(varargin, fields (ebsd.options(:)))
    try
      vnames = fields (ebsd.options(:));
      pos = find_option(varargin,vnames);    
      q = cell2mat(ebsd.options.(varargin{pos}));

      d = calc_color_ind(q,varargin{:});
    catch
      s = options(ebsd);
      s = strcat(s(:),{' '});
      s = [s{:}];
      error('matlab:EBSD:UnknownField', ...
        ['Unknown plot option, might be a spelling mistake ' ...
           '\n  '  s]);
    end
  else
    d = calc_color(@sigma2rgb,ebsd,'q0',q0,varargin{:});
  end  

  

  ix = round(1 + (xy(:,1)-min(x)) ./(max(x)-min(x)) * (numel(x)-1));
  iy = round(1 + (xy(:,2)-min(y)) ./(max(y)-min(y)) * (numel(y)-1));
  ix = max(min(numel(x),ix),1);
  iy = max(min(numel(y),iy),1);  
  
  c = nan(numel(y)*numel(x),3);
  c(iy + (ix-1)*numel(y),:) = d;
  c = reshape(c,numel(y),numel(x),3);
  
  %pcolor(c);shading flat  

  if check_option(varargin,'interpolate')  %numel(find(isnan(c))) / numel(c) > 0.5
    method = get_option(varargin,'interpolate','nearest');
    [xx,yy] = meshgrid(x,y);
    c1 = griddata(xy(:,1),xy(:,2),d(:,1),xx,yy,method);
    c2 = griddata(xy(:,1),xy(:,2),d(:,2),xx,yy,method);
    c3 = griddata(xy(:,1),xy(:,2),d(:,3),xx,yy,method);
    c = cat(3,c1,c2,c3);
    c = min(1,max(c,0));
  end

  if ~check_option(varargin,'white')
    image(x,y,c);
  else
    image(x,y,c,'AlphaData', ~isnan(c(:,:,1)));
  end

  axis equal tight
  set(gcf,'color','w');  
  set(gca,'FontName','Arial Narrow');  
 
  % axis xy
  if ~check_option(varargin,'noscale')
    set(gcf,'units','pixel');
    fig_pos = get(gcf,'position');
    set(gca,'units','pixel');
    d = get_option(varargin,'border',get_mtex_option('border',30));
    a = pbaspect; a = a(1:2)./max(a(1:2));
    b = (fig_pos(3:4) - 2*d);
    c = b./a;
    a = a * min(c);
   
    set(gca,'position',[d d a+10]);  
    
    set(gcf,'position',[fig_pos(1:2) a+2*d]);
    set(gcf,'units','normalized');  
    set(gca,'units','normalized');
  end
  
  dcm_obj = datacursormode(gcf);

  set(dcm_obj,'UpdateFcn',{@drawdata,xy,q}); 
    
  if check_option(varargin,'cursor')
     datacursormode on;
  end
  
end

function d = calc_color(func,ebsd,varargin)

for i=1:numel(ebsd)
  so3 = ebsd.orientations(i);
  d{i,1} = func(quaternion(so3),getCSym(so3), getSSym(so3),varargin{:});
end
d = cell2mat(d);

function d = calc_color_ind(q,varargin)

f = get_option(varargin,'colormap',gray(size(get(gcf,'colormap'),1)));
d = fix((q-min(q))/(max(q)-min(q))*get_option(varargin,'colormapsize',length(f)));
d = ind2rgb(d,colormap(f));

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

function c = euler2rgb(q,varargin)
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


function str = drawdata(empt,eventdata,xy,data)


pos = get(eventdata,'Position');

epsilon = 1e-5;
ind = find( ( xy(:,1) > pos(1)-epsilon & xy(:,1) < pos(1)+epsilon) & ...
            ( xy(:,2) > pos(2)-epsilon & xy(:,2) < pos(2)+epsilon) );

str =  {['(x,y) : ',num2str(pos(1)),', ',num2str(pos(2))]};
if isa(data,'quaternion')
  str = [str,{ ...
          ['quaternion (id: ', num2str(ind),') : ' ], ...
          ['    a = ',num2str(data(ind).a,2)], ...
          ['    b = ', num2str(data(ind).b,2)],...
          ['    c = ', num2str(data(ind).c,2)],...
          ['    d = ', num2str(data(ind).d,2) ]}];
else
   str = [str, ...
         { ['    data = ',num2str(data(ind),6)]}];
end
