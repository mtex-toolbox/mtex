function varargout = slice3(grains,varargin)
% slice through 3d Grains
%
% Input
% grains - @Grain3d
%
% Options
% color - changes the boundary color
% linewidth - changes the width of grain boundary
% PatchProperty - see documentation of patch objects.
%
% Flags
% x|y|z|xy|xyz - specifiy a slicing plane
% dontFill - do not colorize the interior of a grain
%
% See also
% EBSD/slice3

% opts = parseArgs(varargin{:});
% 
% api = getGridApi(ebsd,varargin{:});
% api = getSliceApi(api,opts);
% 


% hold on,

sliceType = get_flag(varargin,{'x','y','z','xy','xz','yz','xyz'},'xyz');
slicePos  = get_option(varargin,sliceType,NaN,'double');

if ~check_option(varargin,'dontFill')
  nphase = numel(grains.phaseMap);
  X = cell(1,nphase);
  for k=1:nphase
    iP =  grains.phase == grains.phaseMap(k);
    [d{k},property] = calcColorCode(grains,iP,varargin{:});
  end
  isPhase = find(~cellfun('isempty',d));
  d = vertcat(d{:});
  
  [ig,id] = find(grains.I_DG(:,any(grains.I_DG,1))');
  d = d(ig,:);
  
  hSlicer  = slice3(grains.ebsd,'property',d,varargin{:});
else
  hSlicer  = addSlicer(sliceType,varargin{:});
end

if numel(slicePos)<=numel(sliceType)
  slicePos(1:numel(sliceType)) = slicePos(1);
end

F = grains.F(any(grains.I_FG,2),:);

Xmin = min(grains.V); Xmax = max(grains.V);

slicePos = (Xmax+Xmin)/2;


plane = struct; n = 0;
planePos = @(p,dim) interlim(p,Xmin(dim),Xmax(dim));

if any(sliceType == 'x')
  n = n+1;
  plane(n).fun = @(p) sliceObj( planePos(p,1),1,grains.V,F);
  plane(n).h   = line();
  
  set(hSlicer(n),'min',Xmin(1),'max',Xmax(1));
end

if any(sliceType == 'y')
  n = n+1;
  plane(n).fun = @(p) sliceObj( planePos(p,2) ,2,grains.V,F);
  plane(n).h   = line();
    
  set(hSlicer(n),'min',Xmin(2),'max',Xmax(2));
end

if any(sliceType == 'z')
  n = n+1;
  plane(n).fun = @(p) sliceObj( planePos(p,3) ,3,grains.V,F);
  plane(n).h   = line();
  
  set(hSlicer(n),'min',Xmin(3),'max',Xmax(3));
end

for k=1:numel(plane)
  
  callBack = get(hSlicer(k),'Callback');

  set(hSlicer(k),'value',slicePos(k),...
    'callback',{@sliceIt,plane(k),callBack});
  
  sliceIt(hSlicer(k),[],plane(k),callBack);
  
end


optiondraw([plane.h],varargin{:});
axlim = [Xmin(:) Xmax(:)]';
grid on
box on
axis (axlim(:),'equal')

view([30,15])


set(gcf,'tag','ebsd_slice3');

if nargout > 0
  varargout{1} = [api.Slicer.hSlicer];
end

function obj = sliceObj(p,dim,V,F)

s = sign(p - V(:,dim));
sF = reshape(s(F,:),size(F));
sel = any(sF<=0,2) & any(sF>=0,2);

F = F(sel,:);
F(:,end+1) = F(:,1);

Vf = reshape(V(F,:),[size(F) 3]);

edges = diff(sign(p-reshape(Vf(:,:,dim),size(F))),1,2)~=0;

A = find(edges);
edges(:,2:end+1)= edges;
edges(:,1) = 0;
B = find(edges);

Vf = reshape(Vf,[],3);
a = Vf(A,:) + bsxfun(@times,(Vf(B,:)-Vf(A,:)),...
  abs(Vf(A,dim)-p)./abs(Vf(A,dim)-Vf(B,dim)));

obj.XData = reshape(a(:,1),[],2)';
obj.XData(3,:) = NaN;
obj.XData = obj.XData(:);
obj.YData = reshape(a(:,2),[],2)';
obj.YData(3,:) = NaN;
obj.YData = obj.YData(:);
obj.ZData = reshape(a(:,3),[],2)';
obj.ZData(3,:) = NaN;
obj.ZData = obj.ZData(:);


function sliceIt(ev,v,plane,callBack)

p = get(ev,'value');

obj = plane.fun(p);
set(plane.h,obj);

if nargin > 3 && ~isempty(callBack)  
  feval(callBack{1},ev,[],callBack{2:end});
end



function y = interlim(x,xmin,xmax)

if x<=xmin
  y = xmin;
elseif x>xmax
  y = xmax;
else
  y = x;
%   y = x.*(xmax-xmin)+xmin;
end

function  hSlicer = addSlicer(sliceType,varargin)

fpos = -10;

if strcmpi(get(gcf,'tag'),'ebsd_slice3')
  hSliders = findall(gcf,'Style','slider');
  fpos = max(cellfun(@(x) x(1),ensurecell(get(hSliders,'position'))))+10;
else
  fpos = -10;
end

for k=1:numel(sliceType)
  
  fpos = fpos+20;
  
  hSlicer(k) = uicontrol(...
    'units','pixels',...
    'backgroundcolor',[0.9 0.9 0.9],...   'callback',{@sliceitz,x,y,z,z},...        'callback',{@(e,eb) sliceit(getappdata(gcbf,'slicedata'),get(e,'value'))},...
    'position',[fpos 10 16 120],...
    'style','slider');
  uicontrol('position',[fpos 130 16 16],...
    'string',sliceType(k),'style','text');
  
end

set(gcf,'toolbar','figure')


