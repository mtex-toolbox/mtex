function ebsdColorbar(varargin)

% input check
if nargin >= 1 && isa(varargin{1},'symmetry')  
  cs = varargin{1};
  colorcoding = varargin{2};
  varargin = varargin(3:end);
  r = xvector;
else
  cs = getappdata(gcf,'CS');
  r = getappdata(gcf,'r');
  colorcoding = getappdata(gcf,'colorcoding');  
end

% S2 Grid
[e1,maxtheta,maxrho] = getFundamentalRegion(cs,symmetry,varargin{:});
h = S2Grid('PLOT',...
  'MAXTHETA',maxtheta,...
  'MAXRHO',maxrho,varargin{:},'resolution',1.5*degree);

d = colorcoding(h);

%[d,map] = rgb2ind(d,256);
figure
plot(h,'data',d,'rgb');
%plot(h,'data',d,'texturemap');
%colormap(map);
set(gcf,'tag','ipdf');
setappdata(gcf,'CS',cs);
setappdata(gcf,'SS',symmetry);
setappdata(gcf,'r',r);
