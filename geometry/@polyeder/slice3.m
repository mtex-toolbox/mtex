function slice3(p,varargin)
% slice through polytope,  TODO
%
%% Option
% margin -  around slicing plane
%
%%
%




slicetype = get_flag(varargin,{'x','y','z','xy','xz','yz','xyz'},'xyz');
[sl, plane] = addslicer(slicetype,varargin{:});


d = colorcode(p,varargin{:});
p = polyeder(p);


cs = cellfun('size',{p.Faces},1);
csz = cellfun('size',{p.Vertices},1);
Vertices = vertcat(p.Vertices);
Faces = vertcat(p.Faces);

css = [0 cumsum(cs)];
csz = [0 cumsum(csz)];

CData = NaN(css(end),3);

for k=1:numel(cs)
  ndx = css(k)+1:css(k+1);
  Faces(ndx,:) = Faces(ndx,:)+csz(k);
  if ~isempty(d)
    CData(ndx,1) = d(k,1);
    CData(ndx,2) = d(k,2);
    CData(ndx,3) = d(k,3);
  else
    CData(ndx,1:3) = 0.8;
  end
end

ax = min(Vertices);
bx = max(Vertices);

pos = get_option(varargin,slicetype,mean([ax;bx]));


Vf = reshape(Vertices(Faces,:),[size(Faces),3]);

Vxl = min(Vf(:,:,1),[],2);
Vxr = max(Vf(:,:,1),[],2);
Vyl = min(Vf(:,:,2),[],2);
Vyr = max(Vf(:,:,2),[],2);
Vzl = min(Vf(:,:,3),[],2);
Vzr = max(Vf(:,:,3),[],2);

h = [];

param.Faces = Faces;
param.CData = CData;
param.margin = get_option(varargin,'margin',.01);


if any(plane==3)
  sx = sl(plane==3);
  
  h(end+1) = patch('Vertices',Vertices,'Faces',Faces(1,:),'FaceVertexCData',CData(1,:),'FaceColor','flat');
  
  zparam = param;
  zparam.l = Vzl;
  zparam.r = Vzr;
  zparam.i = ax(3);
  zparam.j = bx(3);
  
  set(sx,'callback',{@sliceit,h(end),zparam});
  sliceit(sx,[],h(end),zparam,pos(end));
end



if any(plane==2)
  sx = sl(plane==2);
  
  if any(strcmpi(slicetype,'x'))
    pp = pos(2);
  else
    pp = pos(1);
  end
    
  h(end+1) = patch('Vertices',Vertices,'Faces',Faces(1,:),'FaceVertexCData',CData(1,:),'FaceColor','flat');
  
  yparam = param;
  yparam.l = Vyl;
  yparam.r = Vyr;
  yparam.i = ax(2);
  yparam.j = bx(2);
  
  set(sx,'callback',{@sliceit,h(end),yparam});
  sliceit(sx,[],h(end),yparam,pp);
end


if any(plane==1)
  sx = sl(plane==1);
  
  h(end+1) = patch('Vertices',Vertices,'Faces',Faces(1,:),'FaceVertexCData',CData(1,:),'FaceColor','flat');
  
  xparam = param;
  xparam.l = Vxl;
  xparam.r = Vxr;
  xparam.i = ax(1);
  xparam.j = bx(1);
  
  set(sx,'callback',{@sliceit,h(end),xparam});
  sliceit(sx,[],h(end),xparam,pos(1));
end

optiondraw(h,varargin{:});



axis equal
b = [ax(:)';bx(:)'];
axis(b(:)')
grid on
view(30,15)



function  sliceit(e,v,h,planeparam,pos)

if nargin < 5
  pos = planeparam.i+(planeparam.j-planeparam.i)*get(e,'value');
end

intersect = planeparam.l <= pos+planeparam.margin & planeparam.r >= pos-planeparam.margin;

set(h,'Faces',planeparam.Faces(intersect,:),...
  'FaceVertexCData',planeparam.CData(intersect,:));



function d = colorcode(grains,varargin)

property = lower(get_option(varargin,'property','orientation'));

if ~isempty(property)
  
  % orientation to color
  if strcmpi(property,'orientation')
    
    cc = lower(get_option(varargin,'colorcoding','ipdf'));
    
    [phase,uphase]= get(grains,'phase');
    CS = cell(size(uphase));
    
    d = zeros(numel(grains),3);
    for k=1:numel(uphase)
      sel = phase == uphase(k);
      o = get(grains(sel),property);
      CS{k} = get(o,'CS');
      
      c = orientation2color(o,cc,varargin{:});
      d(sel,:) = reshape(c,[],3);
    end
    %
    %     setappdata(gcf,'CS',CS);
    %     setappdata(gcf,'r',get_option(varargin,'r',xvector,'vector3d'));
    %     setappdata(gcf,'colorcenter',get_option(varargin,'colorcenter',[]));
    %     setappdata(gcf,'colorcoding',cc);
    %     setappdata(gcf,'options',extract_option(varargin,'antipodal'));
    
  elseif strcmpi(property,'none')
    
    d = [];
    % property to color
  elseif any(strcmpi(property, fields(grains))) ||...
      any(strcmpi(property,fields(grains(1).properties)))
    
    d = reshape(get(grains,property),[],1);
    
    if strcmpi(property,'phase')
      colormap(hsv(max(d)+1));
    end
    
  elseif  isnumeric(property) && ( ...
      length(grains) == length(property) || islogical(property) || ...
      numel(property) == 1)
    
    d = reshape(property,[],1);
    
  end
  
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