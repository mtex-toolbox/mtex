function slice3(ebsd,varargin)


plotx2east

% % default plot options
varargin = set_default_option(varargin,...
  get_mtex_option('default_plot_options'));



% s.xyz = ebsd.X;
s.xyz = get(ebsd,'X');
assert(size(s.xyz,2) == 3,'data should be 3d');

[s.x s.y s.z] = deal(s.xyz(:,1),s.xyz(:,2),s.xyz(:,3));

s.xx = unique(s.x);
s.yy = unique(s.y);
s.zz = unique(s.z);

newMTEXplot;

addSlicer(varargin);


s.d = colorcode(ebsd,varargin{:});

[s.zxx s.zyy] = meshgrid(s.xx,s.yy);
[s.yxx s.yzz] = meshgrid(s.xx,s.zz);
[s.xyy s.xzz] = meshgrid(s.yy,s.zz);

s.xy = [s.zxx(:) s.zyy(:)];
s.xz = [s.yxx(:) s.yzz(:)];
s.yz = [s.xyy(:) s.xzz(:)];

s.dz = NaN(length(s.xy),size(s.d,2));
s.dy = NaN(length(s.xz),size(s.d,2));
s.dx = NaN(length(s.yz),size(s.d,2));

s.hz = plotxyexact(s.xy,s.dz,[],'voronoi',varargin{:});
s.hy = plotxyexact(s.xz,s.dy,[],'voronoi',varargin{:});
s.hx = plotxyexact(s.yz,s.dx,[],'voronoi',varargin{:});


xyzt = get(s.hy,'Vertices');
[xyzt(:,1),xyzt(:,3)] = deal(xyzt(:,1),xyzt(:,2));
xyzt(:,2) = 0;
set(s.hy,'Vertices',xyzt);


xyzt = get(s.hx,'Vertices');
[xyzt(:,2),xyzt(:,3)] = deal(xyzt(:,1),xyzt(:,2));
xyzt(:,1) = 0;
set(s.hx,'Vertices',xyzt);


view(3)

axis equal
axis ([min(s.xx) max(s.xx) min(s.yy) max(s.yy) min(s.zz) max(s.zz)])
 
setappdata(gcf,'slicedata',s);


 
function sliceitZ(e,eb)
  
  s = getappdata(gcbf,'slicedata');
  
  
  
  
  k = interp1(s.zz,1:numel(s.zz),(max(s.zz)-min(s.zz))*get(e,'Value')+min(s.zz),'nearest');
  zslice = s.z == s.zz(k);
%   s.zz(k)
  tx = s.xyz(zslice,1);
  ty = s.xyz(zslice,2);
  
  ind = interp2(s.zxx,s.zyy,reshape(1:numel(s.zxx),size(s.zxx)),tx,ty,'nearest');
    
  xyzt = get(s.hz,'Vertices');
  xyzt(:,3) = s.zz(k);
  set(s.hz,'Vertices',xyzt);
  
  s.dz(ind,:) = s.d(zslice,:);
  if size(s.dz,2) == 1
    set(s.hz,'CData',s.dz)
  else
    set(s.hz,'FaceVertexCData',s.dz);
  end
  
  
function sliceitY(e,eb)
  
  s = getappdata(gcbf,'slicedata');
   
  
  k = interp1(s.yy,1:numel(s.yy),(max(s.yy)-min(s.yy))*get(e,'Value')+min(s.yy),'nearest');

  yslice = s.y == s.yy(k);
  tx = s.xyz(yslice,1);
  tz = s.xyz(yslice,3);
 
  ind = interp2(s.yxx,s.yzz,reshape(1:numel(s.yxx),size(s.yzz)),tx,tz,'nearest');
  
  xyzt = get(s.hy,'Vertices');
  xyzt(:,2) = s.yy(k);
  set(s.hy,'Vertices',xyzt);
%  s.yy(k)
  dod = isfinite(ind);  
  fyslice = find(yslice);
  s.dy(ind(dod),:) = s.d(fyslice(dod),:);
 
  if size(s.dy,2) == 1
    set(s.hy,'CData',s.dy);
  else
    set(s.hy,'FaceVertexCData',s.dy);
  end  
  
  
function sliceitX(e,eb)
  
  s = getappdata(gcbf,'slicedata');

  k = interp1(s.xx,1:numel(s.xx),(max(s.xx)-min(s.xx))*get(e,'Value')+min(s.xx),'nearest');
  xslice = s.x == s.xx(k);
%  s.xx(k)
  ty = s.xyz(xslice,2);
  tz = s.xyz(xslice,3);
    
  ind = interp2(s.xyy,s.xzz,reshape(1:numel(s.xyy),size(s.xyy)),ty,tz,'nearest');
    
  xyzt = get(s.hx,'Vertices');
  xyzt(:,1) = s.xx(k);
  set(s.hx,'Vertices',xyzt);
  
  dod = isfinite(ind);  
  fxslice = find(xslice);
  s.dx(ind(dod),:) = s.d(fxslice(dod),:);
  if size(s.dx,2) == 1
    set(s.hx,'CData',s.dx)
  else
    set(s.hx,'FaceVertexCData',s.dx);
  end


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


function addSlicer(varargin)
    slicetype = get_flag(varargin,{'x','y','z','xy','xz','yz','xyz'},'xyz');
    
    fpos = -10;
    if ~isempty(strfind(slicetype,'z'))
      fpos = fpos+20;
      h2 = uicontrol(...
        'Units','pixels',...
        'BackgroundColor',[0.9 0.9 0.9],...   'Callback',{@sliceitz,x,y,z,Z},...
        'Callback',{@sliceitZ},...
        'Position',[fpos 10 16 120],...
        'Style','slider',...
        'Tag','z');
       uicontrol('Position',[fpos 130 16 16],...
        'String','z','Style','text');
%       uibutton('Position',[fpos 130 16 20],'String',labelz,'Interpreter','tex')
    end

    if ~isempty(strfind(slicetype,'y'))
      fpos = fpos+20;
      h2 = uicontrol(...
        'Units','pixels',...
        'BackgroundColor',[0.9 0.9 0.9],...        'Callback',{@sliceity,x,y,z,Z},...
         'Callback',{@sliceitY},...
        'Position',[fpos 10 16 120],...
        'Style','slider',...
        'Tag','y');
       uicontrol('Position',[fpos 130 16 16],...
        'String','y','Style','text');
%     uibutton('Position',[fpos 130 16 20],'String',labely,'Interpreter','tex')

    end
    
    if ~isempty(strfind(slicetype,'x'))
      fpos = fpos+20;
      h2 = uicontrol(...
        'Units','pixels',...
        'BackgroundColor',[0.9 0.9 0.9],...  
         'Callback',{@sliceitX},...
        'Position',[fpos 10 16 120],...
        'Style','slider',...
        'Tag','x');
      uicontrol('Position',[fpos 130 16 16],...
        'String','x','Style','text');
%       uibutton('Position',[fpos 130 16 20],'String',labelx,'Interpreter','tex')

    end
    
    set(gcf,'Toolbar','figure')
    
