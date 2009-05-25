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
  o = getappdata(gcf,'options');
  varargin = {o{:},varargin{:}};
  colorcoding = getappdata(gcf,'colorcoding');  
  varargin = set_default_option(varargin,[],'rotate',getappdata(gcf,'rotate'));
end

% get default options
varargin = set_default_option(varargin,...
  get_mtex_option('default_plot_options'));

% S2 Grid
[maxtheta,maxrho,minrho,v] = getFundamentalRegionPF(cs,varargin{:});
h = S2Grid('PLOT','MAXTHETA',maxtheta,'MAXRHO',maxrho,'MINRHO',minrho,'resolution',1*degree,varargin{:});

d = reshape(colorcoding(h),[GridSize(h),3]);

figure
multiplot(@(i) h,@(i) d,1,'rgb',varargin{:});
set(gcf,'tag','ipdf');
setappdata(gcf,'CS',cs);
setappdata(gcf,'SS',symmetry);
setappdata(gcf,'r',r);
setappdata(gcf,'options',extract_option(varargin,'axial'));

%% annotate crystal directions

annotate(v,'MarkerFaceColor','k','labeled','all');
set(gcf,'renderer','opengl');




